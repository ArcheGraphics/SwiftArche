//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// The character controllers.
public class CharacterController: Collider {
    private var _stepOffset: Float = 0.5
    private var _nonWalkableMode: ControllerNonWalkableMode = .PreventClimbing
    private var _upDirection = Vector3(0, 1, 0)
    private var _slopeLimit: Float = 0.707

    /// The controller behavior
    public var behavior: ControllerBehavior?

    /// The step offset for the controller.
    public var stepOffset: Float {
        get {
            _stepOffset
        }
        set {
            _stepOffset = newValue
            (_nativeCollider as! PhysXCharacterController).setStepOffset(newValue)
        }
    }

    /// The value of the non-walkable mode.
    public var nonWalkableMode: ControllerNonWalkableMode {
        get {
            _nonWalkableMode
        }
        set {
            _nonWalkableMode = newValue
            (_nativeCollider as! PhysXCharacterController).setNonWalkableMode(newValue.rawValue)
        }
    }

    /// The up direction for the controller.
    public var upDirection: Vector3 {
        get {
            _upDirection
        }
        set {
            _upDirection = newValue
            (_nativeCollider as! PhysXCharacterController).setUpDirection(newValue)
        }
    }

    /// The slope limit for the controller.
    public var slopeLimit: Float {
        get {
            _slopeLimit
        }
        set {
            _slopeLimit = newValue
            (_nativeCollider as! PhysXCharacterController).setSlopeLimit(newValue)
        }
    }
    
    public var collisionFlags: ControllerCollisionFlag {
        (_nativeCollider as! PhysXCharacterController).getCollisionFlags()
    }
    
    public var isGrounded: Bool {
        collisionFlags.contains(ControllerCollisionFlag.Down)
    }

    public required init(_ entity: Entity) {
        super.init(entity)
        _nativeCollider = PhysXPhysics.createCharacterController()
        (_nativeCollider as! PhysXCharacterController).setHitReport { [self] id, dir, length, normal, point in
            if let behavior,
               let shape = engine.physicsManager._getColliderShape(id) {
                var result = ControllerColliderHit(self)
                result.colliderShape = shape
                result.collider = shape.collider
                result.entity = shape.collider?.entity
                result.moveDirection = dir
                result.moveLength = length
                result.normal = normal
                result.point = point
                behavior.onShapeHit(hit: result)
            }
        }
        (_nativeCollider as! PhysXCharacterController).setBehaviorCallback { [self] id in
            if let behavior,
               let shape = engine.physicsManager._getColliderShape(id) {
                return behavior.getShapeBehaviorFlags(shape: shape).rawValue
            }
            return 0
        }
    }

    /// Moves the character using a "collide-and-slide" algorithm.
    /// - Parameters:
    ///   - disp: Displacement vector
    ///   - minDist: The minimum travelled distance to consider.
    ///   - elapsedTime: Time elapsed since last call
    /// - Returns:The ControllerCollisionFlag
    @discardableResult
    public func move(disp: Vector3, minDist: Float, elapsedTime: Float) -> ControllerCollisionFlag {
        ControllerCollisionFlag(rawValue: (_nativeCollider as! PhysXCharacterController).move(disp, minDist, elapsedTime))
    }

    /// Add collider shape on this controller.
    /// - Parameter shape: Collider shape
    public override func addShape(_ shape: ColliderShape) {
        if (_shapes.count > 0) {
            fatalError("only allow single shape on controller!")
        }
        super.addShape(shape)
        _updateFlag.flag = true
    }

    /// Remove all shape attached.
    public override func clearShapes() {
        if (_shapes.count > 0) {
            super.removeShape(_shapes[0])
        }
    }

    override func _onUpdate() {
        if (_updateFlag.flag) {
            (_nativeCollider as! PhysXCharacterController).setWorldPosition(entity.transform.worldPosition)

            let worldScale = entity.transform.lossyWorldScale
            for shape in _shapes {
                shape._nativeShape.setWorldScale(worldScale)
            }
            _updateFlag.flag = false
        }
    }

    override func _onLateUpdate() {
        entity.transform.worldPosition = (_nativeCollider as! PhysXCharacterController).getWorldPosition()
        _updateFlag.flag = false
    }

    override func _onEnable() {
        engine.physicsManager._addCharacterController(self)
    }

    override func _onDisable() {
        engine.physicsManager._removeCharacterController(self)
    }
}

public struct ControllerCollisionFlag: OptionSet {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    /// Character is colliding to the sides.
    public static let Sides = ControllerCollisionFlag(rawValue: 1 << 0)
    /// Character has collision above.
    public static let Up = ControllerCollisionFlag(rawValue: 1 << 1)
    /// Character has collision below.
    public static let Down = ControllerCollisionFlag(rawValue: 1 << 2)
}
