//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct UpdateVelocitiesJob {
    public private(set) var activeParticles: [Int]

    // linear/position properties:
    public private(set) var inverseMasses: [Float]
    public private(set) var previousPositions: [float4]
    public var positions: [float4]
    public private(set) var velocities: [float4]

    // angular/orientation properties:
    public private(set) var inverseRotationalMasses: [Float]
    public private(set) var previousOrientations: [quaternion]
    public var orientations: [quaternion]
    public private(set) var angularVelocities: [float4]

    public private(set) var deltaTime: Float
    public private(set) var is2D: Bool

    // The code actually running on the job
    public func Execute(index _: Int) {}
}
