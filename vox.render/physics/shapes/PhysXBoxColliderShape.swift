//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Box collider shape in PhysX.
class PhysXBoxColliderShape: PhysXColliderShape {
    private static var _tempHalfExtents = Vector3()
    private var _halfSize: Vector3 = Vector3()

    /// Init Box Shape and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark Shape.
    ///   - size: Size of Shape.
    ///   - material: Material of PhysXCollider.
    init(_ uniqueID: Int, _ size: Vector3, _ material: PhysXPhysicsMaterial) {
        _ = _halfSize.set(x: size.x * 0.5, y: size.y * 0.5, z: size.z * 0.5)
        super.init()

        _pxGeometry = CPxBoxGeometry(
                hx: _halfSize.x * _scale.x,
                hy: _halfSize.y * _scale.y,
                hz: _halfSize.z * _scale.z
        )
        _allocShape(material)
        _setLocalPose()
        setUniqueID(uniqueID)
    }

    func setSize(_ size: Vector3) {
        _ = _halfSize.set(x: size.x * 0.5, y: size.y * 0.5, z: size.z * 0.5)
        (_pxGeometry as! CPxBoxGeometry).halfExtents = (_halfSize * _scale).internalValue
        _pxShape.setGeometry(_pxGeometry)
    }

    override func setWorldScale(_ scale: Vector3) {
        _scale = scale
        (_pxGeometry as! CPxBoxGeometry).halfExtents = (_halfSize * _scale).internalValue
        _pxShape.setGeometry(_pxGeometry)
    }
}
