//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct UpdatePositionsJob {
    public private(set) var activeParticles: [Int]

    // linear/position properties:
    public var positions: [float4]
    public private(set) var previousPositions: [float4]
    public var velocities: [float4]

    // angular/orientation properties:
    public var orientations: [quaternion]
    public private(set) var previousOrientations: [quaternion]
    public var angularVelocities: [float4]

    public private(set) var velocityScale: Float
    public private(set) var sleepThreshold: Float

    // The code actually running on the job
    public func Execute(index _: Int) {}
}
