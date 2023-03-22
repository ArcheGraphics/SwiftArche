//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// The character controllers.
public class CharacterController: Collider {
    /// The controller behavior
    public var behavior: ControllerBehavior?

    /// The step offset for the controller.
    @Serialized(default: 0.5)
    public var stepOffset: Float {
        didSet {
            (_nativeCollider as! PhysXCharacterController).setStepOffset(stepOffset)
        }
    }

    /// The value of the non-walkable mode.
    @Serialized(default: .PreventClimbing)
    public var nonWalkableMode: ControllerNonWalkableMode {
        didSet {
            (_nativeCollider as! PhysXCharacterController).setNonWalkableMode(nonWalkableMode.rawValue)
        }
    }

    /// The up direction for the controller.
    @Serialized(default: Vector3(0, 1, 0))
    public var upDirection: Vector3 {
        didSet {
            (_nativeCollider as! PhysXCharacterController).setUpDirection(upDirection)
        }
    }

    /// The slope limit for the controller.
    @Serialized(default: 0.707)
    public var slopeLimit: Float {
        didSet {
            (_nativeCollider as! PhysXCharacterController).setSlopeLimit(slopeLimit)
        }
    }
    
    public var collisionFlags: ControllerCollisionFlag {
        (_nativeCollider as! PhysXCharacterController).getCollisionFlags()
    }
    
    public var isGrounded: Bool {
        collisionFlags.contains(ControllerCollisionFlag.Down)
    }

    required init() {
        super.init()
        _nativeCollider = PhysXPhysics.createCharacterController()
        (_nativeCollider as! PhysXCharacterController).setHitReport { [self] id, dir, length, normal, point in
            if let behavior,
               let shape = Engine.physicsManager._getColliderShape(id) {
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
               let shape = Engine.physicsManager._getColliderShape(id) {
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
            super.removeShape(_shapes[0].wrappedValue)
        }
    }

    override func _onUpdate() {
        if (_updateFlag.flag) {
            (_nativeCollider as! PhysXCharacterController).setWorldPosition(entity.transform.worldPosition)

            let worldScale = entity.transform.lossyWorldScale
            for shape in _shapes {
                shape.wrappedValue._nativeShape.setWorldScale(worldScale)
            }
            _updateFlag.flag = false
        }
    }

    override func _onLateUpdate() {
        entity.transform.worldPosition = (_nativeCollider as! PhysXCharacterController).getWorldPosition()
        _updateFlag.flag = false
    }

    override func _onEnable() {
        Engine.physicsManager._addCharacterController(self)
    }

    override func _onDisable() {
        Engine.physicsManager._removeCharacterController(self)
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
