//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Plane collider shape in PhysX.
class PhysXPlaneColliderShape: PhysXColliderShape {
    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - material: Material of PhysXCollider
    init(_ uniqueID: Int, _ material: PhysXPhysicsMaterial) {
        super.init()

        _pxGeometry = CPxPlaneGeometry()
        _allocShape(material)
        _setLocalPose()
        setUniqueID(uniqueID)
    }

    func setRotation(_ value: Vector3) {
        _rotation = Quaternion.rotationYawPitchRoll(yaw: value.x, pitch: value.y, roll: value.z)
        _rotation = Quaternion.rotateZ(quaternion: _rotation, rad: Float.pi * 0.5)
        _ = _rotation.normalize()
        _setLocalPose()
    }

    override func setWorldScale(_ scale: Vector3) {
    }
}
