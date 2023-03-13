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

    var _updateFlag: BoolUpdateFlag
    var _shapes: [ColliderShape] = []
    private var _visualize: Bool = false

    public var isVisualize: Bool {
        get {
            _visualize
        }
        set {
            _visualize = newValue
            _nativeCollider.setVisualize(newValue)
        }
    }
    
    /// The shapes of this collider.
    public var shapes: [ColliderShape] {
        get {
            _shapes
        }
    }

    required init(_ entity: Entity) {
        _updateFlag = entity.transform.registerWorldChangeFlag()
        super.init(entity)
    }

    /// Add collider shape on this collider.
    /// - Parameter shape: Collider shape
    public func addShape(_ shape: ColliderShape) {
        let oldCollider = shape._collider
        if (oldCollider !== self) {
            if (oldCollider != nil) {
                oldCollider!.removeShape(shape)
            }
            _shapes.append(shape)
            engine.physicsManager._addColliderShape(shape)
            _nativeCollider.addShape(shape._nativeShape)
            shape._collider = self
        }
    }

    /// Remove a collider shape.
    /// - Parameter shape: The collider shape.
    public func removeShape(_  shape: ColliderShape) {
        let index = _shapes.firstIndex { s in
            s === shape
        }

        if (index != nil) {
            _shapes.remove(at: index!)
            _nativeCollider.removeShape(shape._nativeShape)
            engine.physicsManager._removeColliderShape(shape)
            shape._collider = nil
        }
    }

    /// Remove all shape attached.
    public func clearShapes() {
        for i in 0..<_shapes.count {
            _nativeCollider.removeShape(shapes[i]._nativeShape)
            engine.physicsManager._removeColliderShape(shapes[i])
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
        engine.physicsManager._addCollider(self)
    }


    override func _onDisable() {
        engine.physicsManager._removeCollider(self)
    }

    override func _onDestroy() {
        clearShapes()
    }
}
