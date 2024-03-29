//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Plane collider shape in PhysX.
class PhysXPlaneColliderShape: PhysXColliderShape {
    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - material: Material of PhysXCollider
    init(_ uniqueID: UInt32, _ material: PhysXPhysicsMaterial) {
        super.init()

        _axis = Quaternion(x: 0, y: 0, z: PhysXColliderShape.halfSqrt, w: PhysXColliderShape.halfSqrt)
        _physxRotation = _axis!
        _pxGeometry = CPxPlaneGeometry()
        _initialize(material._pxMaterial, uniqueID)
        _setLocalPose()
    }

    override func setWorldScale(_ scale: Vector3) {
        _scale = scale
        _setLocalPose()
    }
}
