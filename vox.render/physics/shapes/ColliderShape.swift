//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Abstract class for collider shapes.
public class ColliderShape: Serializable, Polymorphic {
    private static var _idGenerator: UInt32 = 0

    var _id: UInt32
    var _collider: Collider?
    var _nativeShape: PhysXColliderShape!
    
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

    @Serialized(default: false)
    public var isVisualize: Bool {
        didSet {
            _nativeShape.setVisualize(isVisualize)
        }
    }
    
    /// Whether raycast can select it.
    @Serialized(default: true)
    public var isSceneQuery: Bool

    /// Contact offset for this shape.
    @Serialized(default: 0.02)
    public var contactOffset: Float {
        didSet {
            _nativeShape.setContactOffset(contactOffset)
        }
    }

    /// Physical material.
    @Serialized(default: PhysicsMaterial())
    public var material: PhysicsMaterial {
        didSet {
            _nativeShape.setMaterial(material._nativeMaterial)
        }
    }

    /// The local rotation of this ColliderShape.
    @Serialized(default: Vector3())
    public var rotation: Vector3 {
        didSet {
            _nativeShape.setRotation(rotation)
        }
    }

    /// The local position of this ColliderShape.
    @Serialized(default: Vector3())
    public var position: Vector3 {
        didSet {
            _nativeShape.setPosition(position)
        }
    }

    /// True for TriggerShape, false for SimulationShape.
    @Serialized(default: false)
    public var isTrigger: Bool {
        didSet {
            _nativeShape.setIsTrigger(isTrigger)
        }
    }

    public required init() {
        _id = ColliderShape._idGenerator
        ColliderShape._idGenerator += 1
    }
}
