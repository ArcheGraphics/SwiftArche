//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct UpdatePrincipalAxisJob {
    public private(set) var activeParticles: [Int]
    public private(set) var renderableOrientations: [quaternion]
    public private(set) var phases: [Int]
    public private(set) var principalRadii: [float4]

    public var principalAxis: [float4]

    public func Execute(index _: Int) {}
}
