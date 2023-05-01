//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct ApplyInertialForcesJob {
    public private(set) var activeParticles: [Int]
    public private(set) var positions: [float4]
    public private(set) var invMasses: [Float]

    public private(set) var angularVel: float4
    public private(set) var inertialAccel: float4
    public private(set) var eulerAccel: float4

    public private(set) var worldLinearInertiaScale: Float
    public private(set) var worldAngularInertiaScale: Float

    public var velocities: [float4]

    public private(set) var deltaTime: Float

    public func Execute(index _: Int) {}
}
