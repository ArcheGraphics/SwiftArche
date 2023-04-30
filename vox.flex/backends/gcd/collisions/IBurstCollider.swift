//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

protocol IBurstCollider {
    func Contacts(colliderIndex: Int,
                  rigidbodyIndex: Int,
                  rigidbodies: [BurstRigidbody],

                  positions: [float4],
                  orientations: [quaternion],
                  velocities: [float4],
                  radii: [float4],

                  simplices: [Int],
                  simplexBounds: BurstAabb,
                  simplexIndex: Int,
                  simplexStart: Int,
                  simplexSize: Int,

                  contacts: [BurstContact],
                  optimizationIterations: Int,
                  optimizationTolerance: Float)
}
