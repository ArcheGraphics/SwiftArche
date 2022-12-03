//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Box collider shape in PhysX.
class PhysXBoxColliderShape: PhysXColliderShape {
    var _halfSize: Vector3 = Vector3()

    /// Init Box Shape and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark Shape.
    ///   - size: Size of Shape.
    ///   - material: Material of PhysXCollider.
    init(_ uniqueID: UInt32, _ size: Vector3, _ material: PhysXPhysicsMaterial) {
        _halfSize = Vector3(size.x * 0.5, size.y * 0.5, size.z * 0.5)
        super.init()

        _pxGeometry = CPxBoxGeometry(
                hx: _halfSize.x * _scale.x,
                hy: _halfSize.y * _scale.y,
                hz: _halfSize.z * _scale.z
        )
        _initialize(material, uniqueID)
        _setLocalPose()
    }

    func setSize(_ size: Vector3) {
        _halfSize = Vector3(size.x * 0.5, size.y * 0.5, size.z * 0.5)
        (_pxGeometry as! CPxBoxGeometry).halfExtents = (_halfSize * _scale).internalValue
        _pxShape.setGeometry(_pxGeometry)

        for i in 0..<_controllers.count {
            let pxController = _controllers.get(i)!._pxController as! CPxBoxController
            pxController.setHalfHeight(_halfSize.x)
            pxController.setHalfSideExtent(_halfSize.y)
            pxController.setHalfForwardExtent(_halfSize.z)
        }
    }

    override func setWorldScale(_ scale: Vector3) {
        _scale = scale
        _setLocalPose()

        (_pxGeometry as! CPxBoxGeometry).halfExtents = (_halfSize * _scale).internalValue
        _pxShape.setGeometry(_pxGeometry)
    }
}
