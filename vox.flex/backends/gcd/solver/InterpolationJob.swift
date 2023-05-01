//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct InterpolationJob {
    public private(set) var startPositions: [float4]
    public private(set) var positions: [float4]
    public private(set) var renderablePositions: [float4]

    public private(set) var startOrientations: [quaternion]
    public private(set) var orientations: [quaternion]
    public private(set) var renderableOrientations: [quaternion]

    public private(set) var deltaTime: Float
    public private(set) var unsimulatedTime: Float
    public private(set) var interpolationMode: Oni.SolverParameters.Interpolation

    // The code actually running on the job
    public func Execute(index _: Int) {}
}
