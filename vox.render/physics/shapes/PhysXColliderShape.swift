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

    var _scale: Vector3 = Vector3(1, 1, 1)
    var _position: Vector3 = Vector3()
    var _rotation: Vector3? = nil
    var _axis: Quaternion? = nil
    var _physxRotation: Quaternion = Quaternion()

    private var _shapeFlags: UInt8 = ShapeFlag.SCENE_QUERY_SHAPE.rawValue | ShapeFlag.SIMULATION_SHAPE.rawValue

    var _controllers: DisorderedArray<PhysXCharacterController> = DisorderedArray()
    var _pxMaterial: CPxMaterial!
    var _pxShape: CPxShape!
    var _pxGeometry: CPxGeometry!
    var _id: UInt32!
    var _contactOffset: Float = 0

    func setRotation(value: Vector3) {
        _rotation = value
        _physxRotation = Quaternion.rotationYawPitchRoll(yaw: value.x, pitch: value.y, roll: value.z)
        if (_axis != nil) {
            _physxRotation = _physxRotation * _axis!
        }
        _ = _physxRotation.normalize()
        _setLocalPose()
    }

    func setPosition(_ position: Vector3) {
        _position = position
        _setLocalPose()
    }

    func setWorldScale(_ scale: Vector3) {
        fatalError("use subClass")
    }

    func setContactOffset(offset: Float) {
        _contactOffset = offset
        _pxShape.setContactOffset(offset)

        for i in 0..<_controllers.length {
            _controllers.get(i)!._pxController.setContactOffset(offset)
        }
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

    func _setShapeFlags(_ flags: UInt8) {
        _shapeFlags = flags
        _pxShape.setFlags(_shapeFlags)
    }

    func _setLocalPose() {
        _pxShape.setLocalPose((_position * _scale).internalValue, rotation: _physxRotation.internalValue)
    }

    func _initialize(_ material: PhysXPhysicsMaterial, _ id: UInt32) {
        _id = id;
        _pxMaterial = material._pxMaterial;
        _pxShape = PhysXPhysics._pxPhysics.createShape(
                with: _pxGeometry,
                material: material._pxMaterial,
                isExclusive: true,
                shapeFlags: _shapeFlags
        )
        _pxShape.setQueryFilterData(id, w1: 0, w2: 0, w3: 0)
    }

    private func _modifyFlag(_ flag: UInt8, _ value: Bool) {
        _shapeFlags = value ? _shapeFlags | flag : _shapeFlags & ~flag
    }
}
