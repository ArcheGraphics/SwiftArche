//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct PredictPositionsJob {
    public private(set) var activeParticles: [Int]
    public private(set) var phases: [Int]
    public private(set) var buoyancies: [Float]

    // linear/position properties:
    public private(set) var externalForces: [float4]
    public private(set) var inverseMasses: [Float]
    public var previousPositions: [float4]
    public var positions: [float4]
    public var velocities: [float4]

    // angular/orientation properties:
    public private(set) var externalTorques: [float4]
    public private(set) var inverseRotationalMasses: [Float]
    public var previousOrientations: [quaternion]
    public var orientations: [quaternion]
    public var angularVelocities: [float4]

    public private(set) var gravity: float4
    public private(set) var deltaTime: Float
    public private(set) var is2D: Bool

    public func Execute(index _: Int) {}
}
