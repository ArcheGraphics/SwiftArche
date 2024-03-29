//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Sphere collider shape in PhysX.
class PhysXSphereColliderShape: PhysXColliderShape {
    private var _radius: Float
    private var _maxScale: Float = 1

    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - radius: Size of SphereCollider
    ///   - material: Material of PhysXCollider
    init(_ uniqueID: UInt32, _ radius: Float, _ material: PhysXPhysicsMaterial) {
        _radius = radius

        super.init()

        _pxGeometry = CPxSphereGeometry(radius: _radius * _maxScale)
        _initialize(material._pxMaterial, uniqueID)
        _setLocalPose()
    }

    func setRadius(_ value: Float) {
        _radius = value
        (_pxGeometry as! CPxSphereGeometry).radius = value * _maxScale
        _pxShape.setGeometry(_pxGeometry)
    }

    override func setWorldScale(_ scale: Vector3) {
        _scale = scale
        _setLocalPose()

        _maxScale = max(scale.x, max(scale.x, scale.y))
        (_pxGeometry as! CPxSphereGeometry).radius = _radius * _maxScale
        _pxShape.setGeometry(_pxGeometry)
    }
}
