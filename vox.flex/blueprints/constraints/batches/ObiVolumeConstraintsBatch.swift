//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiVolumeConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IVolumeConstraintsBatchImpl?

    /// index of the first triangle for each constraint (exclusive prefix sum).
    public var firstTriangle: [Int] = []

    /// number of triangles for each constraint.
    public var numTriangles: [Int] = []

    /// rest volume for each constraint.
    public var restVolumes: [Float] = []

    /// 2 floats per constraint: pressure and stiffness.
    public var pressureStiffness: [Vector2] = []

    public init(constraints _: ObiVolumeConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.Volume
        implementation = m_BatchImpl
    }
}
