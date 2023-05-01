//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiShapeMatchingConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IShapeMatchingConstraintsBatchImpl?

    /// index of the first particle in each constraint.
    public var firstIndex: [Int] = []

    /// amount of particles in each constraint.
    public var numIndices: [Int] = []

    /// whether the constraint is implicit (0) or explicit (>0).
    public var explicitGroup: [Int] = []

    /// 5 floats per constraint: stiffness, plastic yield, creep, recovery and max deformation.
    public var materialParameters: [Float] = []

    /// rest center of mass for each constraint.
    public var restComs: [Vector4] = []

    /// current center of mass for each constraint.
    public var coms: [Vector4] = []

    /// current best-match orientation for each constraint.
    public var orientations: [Quaternion] = []

    /// current best-match linear transform for each constraint.
    public var linearTransforms: [Matrix] = []

    /// current plastic deformation for each constraint.
    public var plasticDeformations: [Matrix] = []

    public init(constraints _: ObiShapeMatchingConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.ShapeMatching
        implementation = m_BatchImpl
    }
}
