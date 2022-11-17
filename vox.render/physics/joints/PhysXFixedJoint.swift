//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXFixedJoint: PhysXJoint {
    init(_ collider: PhysXCollider?) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createFixedJoint(
                nil ?? nil, SIMD3<Float>(), simd_quatf(),
                collider?._pxActor ?? nil, SIMD3<Float>(), simd_quatf()
        )
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionAngularTolerance(tolerance)
    }
}
