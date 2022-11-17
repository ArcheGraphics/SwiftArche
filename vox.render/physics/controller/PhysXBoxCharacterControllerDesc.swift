//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXBoxCharacterControllerDesc: PhysXCharacterControllerDesc {
    override init() {
        super.init()
        _pxControllerDesc = CPxBoxControllerDesc()
    }

    func setToDefault() {
        (_pxControllerDesc as! CPxBoxControllerDesc).setToDefault()
    }

    func setHalfHeight(_ halfHeight: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).halfHeight = halfHeight
    }

    func setHalfSideExtent(_ halfSideExtent: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).halfSideExtent = halfSideExtent
    }

    func setHalfForwardExtent(_ halfForwardExtent: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).halfForwardExtent = halfForwardExtent
    }

    func setPosition(_ position: Vector3) {
        (_pxControllerDesc as! CPxBoxControllerDesc).position = position.internalValue
    }

    func setUpDirection(_ upDirection: Vector3) {
        (_pxControllerDesc as! CPxBoxControllerDesc).upDirection = upDirection.internalValue
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).slopeLimit = slopeLimit
    }

    func setInvisibleWallHeight(_ invisibleWallHeight: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).invisibleWallHeight = invisibleWallHeight
    }

    func setMaxJumpHeight(_ maxJumpHeight: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).maxJumpHeight = maxJumpHeight
    }

    func setContactOffset(_ contactOffset: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).contactOffset = contactOffset
    }

    func setStepOffset(_ stepOffset: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).stepOffset = stepOffset
    }

    func setDensity(_ density: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).density = density
    }

    func setScaleCoeff(_ scaleCoeff: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).scaleCoeff = scaleCoeff
    }

    func setVolumeGrowth(_ volumeGrowth: Float) {
        (_pxControllerDesc as! CPxBoxControllerDesc).volumeGrowth = volumeGrowth
    }

    func setNonWalkableMode(_ nonWalkableMode: Int) {
        (_pxControllerDesc as! CPxBoxControllerDesc).nonWalkableMode = CPxControllerNonWalkableMode(UInt32(nonWalkableMode))
    }

    func setMaterial(_ material: PhysXPhysicsMaterial?) {
        (_pxControllerDesc as! CPxBoxControllerDesc).material = material?._pxMaterial
    }

    func setRegisterDeletionListener(_ registerDeletionListener: Bool) {
        (_pxControllerDesc as! CPxBoxControllerDesc).registerDeletionListener = registerDeletionListener
    }

    func setControllerBehaviorCallback(getShapeBehaviorFlags: @escaping (PhysXColliderShape, PhysXCollider) -> UInt8,
                                       getControllerBehaviorFlags: @escaping (PhysXCharacterController) -> UInt8,
                                       getObstacleBehaviorFlags: @escaping (PhysXObstacle) -> UInt8) {
        (_pxControllerDesc as! CPxBoxControllerDesc).setControllerBehaviorCallback({ (shape: CPxShape, actor: CPxRigidActor) in
            let s = PhysXColliderShape()
            s._pxShape = shape
            let a = PhysXCollider()
            a._pxActor = actor
            return getShapeBehaviorFlags(s, a)
        }, { (controller: CPxController) in
            let c = PhysXCharacterController()
            c._pxController = controller
            return getControllerBehaviorFlags(c)
        }, { (obstacle: CPxObstacle) in
            let o = PhysXObstacle()
            o._pxObstacle = obstacle
            return getObstacleBehaviorFlags(o)
        })
    }
}
