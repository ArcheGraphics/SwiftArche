//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Abstract class for collider shapes.
public class Collider: Component {
    var _index: Int = -1
    var _nativeCollider: PhysXCollider!

    var _updateFlag: BoolUpdateFlag!
    
    @Serialized("shapes", default: [])
    var _shapes: [PolymorphicValue<ColliderShape>]
    
    @Serialized(default: false)
    public var visualize: Bool {
        didSet {
            _nativeCollider.setVisualize(visualize)
        }
    }
    
    /// The shapes of this collider.
    public var shapes: [ColliderShape] {
        get {
            _shapes.map { s in
                s.wrappedValue
            }
        }
    }
    
    public internal(set) override var entity: Entity {
        get {
            _entity
        }
        set {
            super.entity = newValue
            _updateFlag = entity.transform.registerWorldChangeFlag()
        }
    }

    /// Add collider shape on this collider.
    /// - Parameter shape: Collider shape
    public func addShape(_ shape: ColliderShape) {
        let oldCollider = shape._collider
        if (oldCollider !== self) {
            if (oldCollider != nil) {
                oldCollider!.removeShape(shape)
            }
            _shapes.append(PolymorphicValue(wrappedValue: shape, key: .colliderShapeTypes))
            Engine.physicsManager._addColliderShape(shape)
            _nativeCollider.addShape(shape._nativeShape)
            shape._collider = self
        }
    }

    /// Remove a collider shape.
    /// - Parameter shape: The collider shape.
    public func removeShape(_  shape: ColliderShape) {
        let index = _shapes.firstIndex { s in
            s.wrappedValue === shape
        }

        if (index != nil) {
            _shapes.remove(at: index!)
            _nativeCollider.removeShape(shape._nativeShape)
            Engine.physicsManager._removeColliderShape(shape)
            shape._collider = nil
        }
    }

    /// Remove all shape attached.
    public func clearShapes() {
        for i in 0..<_shapes.count {
            _nativeCollider.removeShape(shapes[i]._nativeShape)
            Engine.physicsManager._removeColliderShape(shapes[i])
        }
        _shapes = []
    }

    func setGroup(_ collisionGroup: UInt16) {
        _nativeCollider.setGroup(collisionGroup)
    }

    func _onUpdate() {
        if (_updateFlag.flag) {
            let transform = entity.transform
            _nativeCollider.setWorldTransform(transform!.worldPosition, transform!.worldRotationQuaternion)
            _updateFlag.flag = false

            let worldScale = transform!.lossyWorldScale
            for i in 0..<_shapes.count {
                shapes[i]._nativeShape.setWorldScale(worldScale)
            }
        }
    }

    func _onLateUpdate() {
    }


    override func _onEnable() {
        Engine.physicsManager._addCollider(self)
    }


    override func _onDisable() {
        Engine.physicsManager._removeCollider(self)
    }

    override func _onDestroy() {
        clearShapes()
    }
}
