//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Abstract class for collider shapes.
public class ColliderShape {
    private static var _idGenerator: UInt32 = 0

    var _collider: Collider?
    var _nativeShape: PhysXColliderShape!

    var _id: UInt32
    var _material: PhysicsMaterial
    private var _isTrigger: Bool = false
    private var _isSceneQuery: Bool = true
    private var _contactOffset: Float = 0
    private var _rotation: Vector3 = Vector3()
    private var _position: Vector3 = Vector3()

    /// Collider owner of this shape.
    public var collider: Collider? {
        get {
            _collider
        }
    }

    /// Unique id for this shape.
    public var id: UInt32 {
        get {
            _id
        }
    }

    /// Contact offset for this shape.
    public var contactOffset: Float {
        get {
            _contactOffset
        }
        set {
            _contactOffset = newValue
            _nativeShape.setContactOffset(newValue)
        }
    }

    /// Physical material.
    public var material: PhysicsMaterial {
        get {
            _material
        }
        set {
            _material = newValue
            _nativeShape.setMaterial(newValue._nativeMaterial)
        }
    }

    /// The local rotation of this ColliderShape.
    public var rotation: Vector3 {
        get {
            _rotation
        }
        set {
            _rotation = newValue
            _nativeShape.setRotation(_rotation)
        }
    }

    /// The local position of this ColliderShape.
    public var position: Vector3 {
        get {
            _position
        }
        set {
            _position = newValue
            _nativeShape.setPosition(newValue)
        }
    }

    /// Whether raycast can select it
    public var isSceneQuery: Bool {
        get {
            _isSceneQuery
        }
        set {
            _isSceneQuery = newValue
            _nativeShape.setIsSceneQuery(newValue)
        }
    }

    /// True for TriggerShape, false for SimulationShape.
    public var isTrigger: Bool {
        get {
            _isTrigger
        }
        set {
            _isTrigger = newValue
            _nativeShape.setIsTrigger(newValue)
        }
    }

    init() {
        _material = PhysicsMaterial()
        _id = ColliderShape._idGenerator
        ColliderShape._idGenerator += 1
    }
}
