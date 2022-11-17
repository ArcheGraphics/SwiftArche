//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Capsule collider shape in PhysX.
class PhysXCapsuleColliderShape: PhysXColliderShape {
    var _radius: Float
    var _halfHeight: Float
    private var _upAxis: ColliderShapeUpAxis = ColliderShapeUpAxis.Y

    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - radius: Radius of CapsuleCollider
    ///   - height: Height of CapsuleCollider
    ///   - material: Material of PhysXCollider
    init(_ uniqueID: UInt32, _ radius: Float, _ height: Float, _ material: PhysXPhysicsMaterial) {
        _radius = radius
        _halfHeight = height * 0.5
        super.init()

        _axis = Quaternion(0, 0, PhysXColliderShape.halfSqrt, PhysXColliderShape.halfSqrt)
        _physxRotation = _axis!

        _pxGeometry = CPxCapsuleGeometry(radius: _radius, halfHeight: _halfHeight)
        _initialize(material, uniqueID)
        _setLocalPose()
    }

    func setRadius(_ value: Float) {
        _radius = value
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(_scale.y, _scale.z)
            break
        case ColliderShapeUpAxis.Y:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(_scale.x, _scale.z)
            break
        case ColliderShapeUpAxis.Z:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(_scale.x, _scale.y)
            break
        }
        _pxShape.setGeometry(_pxGeometry)

        for i in 0..<_controllers.length {
            (_controllers.get(i)!._pxController as! CPxCapsuleController).setRadius(value)
        }
    }

    func setHeight(_ value: Float) {
        _halfHeight = value * 0.5
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * _scale.x
            break
        case ColliderShapeUpAxis.Y:
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * _scale.y
            break
        case ColliderShapeUpAxis.Z:
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * _scale.z
            break
        }
        _pxShape.setGeometry(_pxGeometry)

        for i in 0..<_controllers.length {
            (_controllers.get(i)!._pxController as! CPxCapsuleController).setHeight(value)
        }
    }

    func setUpAxis(_ upAxis: Int) {
        _upAxis = ColliderShapeUpAxis(rawValue: upAxis)!
        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            _ = _axis!.set(x: 0, y: 0, z: 0, w: 1)
            break
        case ColliderShapeUpAxis.Y:
            _ = _axis!.set(x: 0, y: 0, z: PhysXColliderShape.halfSqrt, w: PhysXColliderShape.halfSqrt)
            break
        case ColliderShapeUpAxis.Z:
            _ = _axis!.set(x: 0, y: PhysXColliderShape.halfSqrt, z: 0, w: PhysXColliderShape.halfSqrt)
            break
        }

        if (_rotation != nil) {
            _physxRotation = Quaternion.rotationYawPitchRoll(yaw: _rotation!.x, pitch: _rotation!.y, roll: _rotation!.z)
            _physxRotation = _physxRotation * _axis!
        } else {
            _physxRotation = _axis!
        }
        _setLocalPose()
    }

    override func setWorldScale(_ scale: Vector3) {
        _scale = scale
        _setLocalPose()

        switch (_upAxis) {
        case ColliderShapeUpAxis.X:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(scale.y, scale.z)
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * scale.x
            break
        case ColliderShapeUpAxis.Y:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(scale.x, scale.z)
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * scale.y
            break
        case ColliderShapeUpAxis.Z:
            (_pxGeometry as! CPxCapsuleGeometry).radius = _radius * max(scale.x, scale.y)
            (_pxGeometry as! CPxCapsuleGeometry).halfHeight = _halfHeight * scale.z
            break
        }
        _pxShape.setGeometry(_pxGeometry)
    }
}
