//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class PhysXSpringJoint: PhysXJoint {
    private var _swingOffset = Vector3()

    init(_ collider: PhysXCollider?) {
        super.init()
        _collider = collider
        _pxJoint = PhysXPhysics._pxPhysics.createDistanceJoint(
            nil ?? nil, SIMD3<Float>(), simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
            collider?._pxActor ?? nil, SIMD3<Float>(), simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        )
        (_pxJoint as! CPxDistanceJoint).setDistanceJointFlag(CPxDistanceJointFlag(1), true) // enable max distance
        (_pxJoint as! CPxDistanceJoint).setDistanceJointFlag(CPxDistanceJointFlag(2), true) // enable min distance
        (_pxJoint as! CPxDistanceJoint).setDistanceJointFlag(CPxDistanceJointFlag(4), true) // enable spring
    }

    func setSwingOffset(_ value: Vector3) {
        _swingOffset = value
        _setLocalPose(1, value, Quaternion())
    }

    func setMinDistance(_ distance: Float) {
        (_pxJoint as! CPxDistanceJoint).setMinDistance(distance)
    }

    func setMaxDistance(_ distance: Float) {
        (_pxJoint as! CPxDistanceJoint).setMaxDistance(distance)
    }

    func setTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxDistanceJoint).setTolerance(tolerance)
    }

    func setStiffness(_ stiffness: Float) {
        (_pxJoint as! CPxDistanceJoint).setStiffness(stiffness)
    }

    func setDamping(_ damping: Float) {
        (_pxJoint as! CPxDistanceJoint).setDamping(damping)
    }
}
