//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Flags which affect the behavior of Shapes.
enum ShapeFlag: UInt8 {
    /// The shape will partake in collision in the physical simulation.
    case SIMULATION_SHAPE = 1
    /// The shape will partake in scene queries (ray casts, overlap tests, sweeps, ...).
    case SCENE_QUERY_SHAPE = 2
    /// The shape is a trigger which can send reports whenever other shapes enter/leave its volume.
    case TRIGGER_SHAPE = 4
}

/// Abstract class for collider shapes.
class PhysXColliderShape {
    static var halfSqrt: Float = 0.70710678118655

    var _position: Vector3 = Vector3()
    var _rotation: Quaternion = Quaternion(0, 0, PhysXColliderShape.halfSqrt, PhysXColliderShape.halfSqrt)
    var _scale: Vector3 = Vector3(1, 1, 1)

    private var _shapeFlags: UInt8 = ShapeFlag.SCENE_QUERY_SHAPE.rawValue | ShapeFlag.SIMULATION_SHAPE.rawValue
    private var _pxMaterial: CPxMaterial!

    internal var _pxShape: CPxShape!
    internal var _pxGeometry: CPxGeometry!
    internal var _id: Int!

    func setUniqueID(_ id: Int) {
        _id = id
        _pxShape.setQueryFilterData(UInt32(id), w1: 0, w2: 0, w3: 0)
    }

    func setPosition(_ position: Vector3) {
        _position = position
        _setLocalPose()
    }

    func setWorldScale(_ scale: Vector3) {
        fatalError("use subClass")
    }

    func setMaterial(_ material: PhysXPhysicsMaterial) {
        _pxMaterial = material._pxMaterial
        _pxShape.setMaterial(_pxMaterial)
    }

    func setIsTrigger(_ value: Bool) {
        _modifyFlag(ShapeFlag.SIMULATION_SHAPE.rawValue, !value)
        _modifyFlag(ShapeFlag.TRIGGER_SHAPE.rawValue, value)
        _setShapeFlags(_shapeFlags)
    }

    func setIsSceneQuery(_ value: Bool) {
        _modifyFlag(ShapeFlag.SCENE_QUERY_SHAPE.rawValue, value)
        _setShapeFlags(_shapeFlags)
    }

    internal func _setShapeFlags(_ flags: UInt8) {
        _shapeFlags = flags
        _pxShape.setFlags(_shapeFlags)
    }

    func _setLocalPose() {
        _pxShape.setLocalPose(_position.internalValue, rotation: _rotation.internalValue)
    }

    func _allocShape(_ material: PhysXPhysicsMaterial) {
        _pxShape = PhysXPhysics._pxPhysics.createShape(
                with: _pxGeometry,
                material: material._pxMaterial,
                isExclusive: true,
                shapeFlags: _shapeFlags
        )
    }

    private func _modifyFlag(_ flag: UInt8, _ value: Bool) {
        _shapeFlags = value ? _shapeFlags | flag : _shapeFlags & ~flag
    }
}
