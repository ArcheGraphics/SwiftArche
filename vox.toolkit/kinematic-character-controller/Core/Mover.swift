//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// This script handles all physics, collision detection and ground detection
/// It expects a movement velocity (via 'SetVelocity') every 'FixedUpdate' frame from an external script (like a controller script) to work
/// It also provides several getter methods for important information (whether the mover is grounded, the current surface normal [...])
public class Mover: Script {
    //MARK: - Collider variables
    var stepHeightRatio: Float = 0.25
    var colliderHeight: Float = 2
    var colliderThickness: Float = 1
    var colliderOffset = Vector3()

    //MARK: - References to attached collider(s)
    var collider: Collider?

    //MARK: - Sensor variables
    public var sensorType = Sensor.CastType.Raycast
    private var sensorRadiusModifier: Float = 0.8
    private var currentLayer: Layer = []
    var isInDebugMode: Bool = false
    var sensorArrayRows: Int = 1
    var sensorArrayRayCount: Int = 6
    var sensorArrayRowsAreOffset: Bool = false

    public var raycastArrayPreviewPositions: [Vector3] = []

    //MARK: - Ground detection variables
    var isGrounded = false

    //MARK: - Sensor range variables
    var IsUsingExtendedSensorRange = true
    var baseSensorRange: Float = 0

    //MARK: - Current upwards (or downwards) velocity necessary to keep the correct distance to the ground
    var currentGroundAdjustmentVelocity = Vector3()

    //MARK: - References to attached components
    var col: DynamicCollider!
    var tr: Transform!
    var sensor: Sensor!

    public required init(_ entity: Entity) {
        super.init(entity)
    }

    public override func onAwake() {
        Setup()

        //Initialize sensor
        sensor = Sensor(tr, col)
        RecalculateColliderDimensions()
        RecalibrateSensor()
    }

    func Reset() {
        Setup()
    }

    /// Setup references to components
    func Setup() {
        tr = entity.transform
        col = entity.getComponent()

        //If no collider is attached to this gameobject, add a collider
        if (col == nil) {
            let capsule = CapsuleColliderShape()
            col = entity.addComponent()
            col.addShape(capsule)
        }

        collider = entity.getComponent()

        //Freeze rigidbody rotation and disable rigidbody gravity
        col.constraints = [DynamicColliderConstraints.FreezeRotationX,
                           DynamicColliderConstraints.FreezeRotationY,
                           DynamicColliderConstraints.FreezeRotationZ]
        col.useGravity = false
    }

    //Recalculate collider height/width/thickness
    public func RecalculateColliderDimensions() {
        //Check if a collider is attached to this gameobject
        if (col == nil) {
            //Try to get a reference to the attached collider by calling Setup()
            Setup()

            //Check again
            if (col == nil) {
                logger.warning("There is no collider attached to \(entity.name)!")
                return
            }
        }

        //Set collider dimensions based on collider variables
        if let boxCollider = collider?.shapes[0] as? BoxColliderShape {
            var _size = Vector3()
            _size.x = colliderThickness
            _size.z = colliderThickness

            boxCollider.position = colliderOffset * colliderHeight

            _size.y = colliderHeight * (1.0 - stepHeightRatio)
            boxCollider.size = _size

            boxCollider.position = boxCollider.position + Vector3(0, stepHeightRatio * colliderHeight / 2, 0)
        } else if let sphereCollider = collider?.shapes[0] as? SphereColliderShape {
            sphereCollider.radius = colliderHeight / 2
            sphereCollider.position = colliderOffset * colliderHeight

            sphereCollider.position = sphereCollider.position + Vector3(0, stepHeightRatio * sphereCollider.radius, 0)
            sphereCollider.radius *= (1.0 - stepHeightRatio)
        } else if let capsuleCollider = collider?.shapes[0] as? CapsuleColliderShape {
            capsuleCollider.height = colliderHeight
            capsuleCollider.position = colliderOffset * colliderHeight
            capsuleCollider.radius = colliderThickness / 2

            capsuleCollider.position = capsuleCollider.position + Vector3(0, stepHeightRatio * capsuleCollider.height / 2, 0)
            capsuleCollider.height *= (1.0 - stepHeightRatio)

            if (capsuleCollider.height / 2.0 < capsuleCollider.radius) {
                capsuleCollider.radius = capsuleCollider.height / 2
            }
        }

        //Recalibrate sensor variables to fit new collider dimensions
        if (sensor != nil) {
            RecalibrateSensor()
        }
    }

    //Recalibrate sensor variables
    func RecalibrateSensor() {
        //Set sensor ray origin and direction
        sensor.SetCastOrigin(GetColliderCenter())
        sensor.SetCastDirection(Sensor.CastDirection.Down)

        //Calculate sensor layermask
        RecalculateSensorLayerMask()

        //Set sensor cast type
        sensor.castType = sensorType

        //Calculate sensor radius/width
        var _radius: Float = colliderThickness / 2.0 * sensorRadiusModifier

        //Multiply all sensor lengths with '_safetyDistanceFactor' to compensate for floating point errors
        let _safetyDistanceFactor: Float = 0.001

        //Fit collider height to sensor radius
        if let boxCollider = collider?.shapes[0] as? BoxColliderShape {
            _radius = simd_clamp(_radius, _safetyDistanceFactor, (boxCollider.size.y / 2.0) * (1.0 - _safetyDistanceFactor))
        } else if let sphereCollider = collider?.shapes[0] as? SphereColliderShape {
            _radius = simd_clamp(_radius, _safetyDistanceFactor, sphereCollider.radius * Float(1.0 - _safetyDistanceFactor))
        } else if let capsuleCollider = collider?.shapes[0] as? CapsuleColliderShape {
            _radius = simd_clamp(_radius, _safetyDistanceFactor, (capsuleCollider.height / 2.0) * (1.0 - _safetyDistanceFactor))
        }

        //Set sensor variables

        //Set sensor radius
        sensor.sphereCastRadius = _radius * tr.scale.x

        //Calculate and set sensor length
        var _length: Float = 0
        _length += (colliderHeight * (1 - stepHeightRatio)) * 0.5
        _length += colliderHeight * stepHeightRatio
        baseSensorRange = _length * (1.0 + _safetyDistanceFactor) * tr.scale.x
        sensor.castLength = _length * tr.scale.x

        //Set sensor array variables
        sensor.ArrayRows = sensorArrayRows
        sensor.arrayRayCount = sensorArrayRayCount
        sensor.offsetArrayRows = sensorArrayRowsAreOffset
        sensor.isInDebugMode = isInDebugMode

        //Set sensor spherecast variables
        sensor.calculateRealDistance = true
        sensor.calculateRealSurfaceNormal = true

        //Recalibrate sensor to the new values
        sensor.RecalibrateRaycastArrayPositions()
    }

    //Recalculate sensor layermask based on current physics settings
    func RecalculateSensorLayerMask() {
        var _layerMask: Layer = []
        var _objectLayer = entity.layer

        // MARK: TODO
//        //Calculate layermask
//        for i in 0..<32 {
//            if (!engine.physicsManager.GetIgnoreLayerCollision(_objectLayer, i)) {
//                _layerMask = Layer(rawValue: _layerMask.rawValue | (1 << i))
//            }
//        }
//
//        //Make sure that the calculated layermask does not include the 'Ignore Raycast' layer
//        if (_layerMask == (_layerMask | (1 << Layer.NameToLayer("Ignore Raycast")))) {
//            _layerMask ^= (1 << Layer.NameToLayer("Ignore Raycast"))
//        }

        //Set sensor layermask
        sensor.layermask = _layerMask

        //Save current layer
        currentLayer = _objectLayer
    }

    //Returns the collider's center in world coordinates
    func GetColliderCenter() -> Vector3 {
        if (col == nil) {
            Setup()
        }

        // MARK: TODO
        return col.shapes[0].position + col.entity.transform.worldPosition
    }

    //Check if mover is grounded
    //Store all relevant collision information for later
    //Calculate necessary adjustment velocity to keep the correct distance to the ground
    func Check() {
        //Reset ground adjustment velocity
        currentGroundAdjustmentVelocity = Vector3()

        //Set sensor length
        if (IsUsingExtendedSensorRange) {
            sensor.castLength = baseSensorRange + (colliderHeight * tr.scale.x) * stepHeightRatio
        } else {
            sensor.castLength = baseSensorRange
        }

        sensor.Cast(engine: engine)

        //If sensor has not detected anything, set flags and return
        if (!sensor.HasDetectedHit) {
            isGrounded = false
            return
        }

        //Set flags for ground detection
        isGrounded = true

        //Get distance that sensor ray reached
        let _distance = sensor.GetDistance

        //Calculate how much mover needs to be moved up or down
        let _upperLimit = ((colliderHeight * tr.scale.x) * (1 - stepHeightRatio)) * 0.5
        let _middle = _upperLimit + (colliderHeight * tr.scale.x) * stepHeightRatio
        let _distanceToGo = _middle - _distance

        //Set new ground adjustment velocity for the next frame
        currentGroundAdjustmentVelocity = tr.worldUp * (_distanceToGo / engine.physicsManager.fixedTimeStep)
    }

    //Check if mover is grounded
    public func CheckForGround() {
        //Check if object layer has been changed since last frame
        //If so, recalculate sensor layer mask
        if (currentLayer != entity.layer) {
            RecalculateSensorLayerMask()
        }

        Check()
    }

    //Set mover velocity
    public func SetVelocity(_ _velocity: Vector3) {
        col.linearVelocity = _velocity + currentGroundAdjustmentVelocity
    }

    // Returns 'true' if mover is touching ground and the angle
    // between hte 'up' vector and ground normal is not too steep (e.g., angle < slope_limit)
    public func IsGrounded() -> Bool {
        return isGrounded
    }
}

extension Mover {
    //Set whether sensor range should be extended
    public func SetExtendSensorRange(_ isExtended: Bool) {
        IsUsingExtendedSensorRange = isExtended
    }

    //Set height of collider
    public func SetColliderHeight(_ newColliderHeight: Float) {
        if (colliderHeight == newColliderHeight) {
            return
        }

        colliderHeight = newColliderHeight
        RecalculateColliderDimensions()
    }

    //Set thickness/width of collider
    public func SetColliderThickness(_ newColliderThickness: Float) {
        if (colliderThickness == newColliderThickness) {
            return
        }

        var newColliderThickness = newColliderThickness
        if (newColliderThickness < 0) {
            newColliderThickness = 0
        }

        colliderThickness = newColliderThickness
        RecalculateColliderDimensions()
    }

    //Set acceptable step height
    public func SetStepHeightRatio(_ newStepHeightRatio: Float) {
        let newStepHeightRatio = simd_clamp(newStepHeightRatio, 0, 1)
        stepHeightRatio = newStepHeightRatio
        RecalculateColliderDimensions()
    }
}

extension Mover {
    public var groundNormal: Vector3 {
        sensor.GetNormal
    }

    public var groundPoint: Vector3 {
        sensor.GetPosition
    }

    public var groundCollider: Entity {
        sensor.GetCollider
    }
}
