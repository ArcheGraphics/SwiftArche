//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstConstraintsBatchImpl: IConstraintsBatchImpl {
    var m_Constraints: IBurstConstraintsImpl!
    var m_ConstraintType: Oni.ConstraintType!

    var m_Enabled = true
    var m_ConstraintCount = 0

    public var constraintType: Oni.ConstraintType { return m_ConstraintType }

    public var enabled: Bool {
        set {
            if m_Enabled != newValue {
                m_Enabled = newValue
            }
        }
        get { return m_Enabled }
    }

    public var constraints: IConstraints { return m_Constraints }

    public var solverAbstraction: ObiSolver { return (m_Constraints.solver as! BurstSolverImpl).abstraction }

    public var solverImplementation: BurstSolverImpl { return m_Constraints.solver as! BurstSolverImpl }

    var particleIndices: [Int] = []
    var lambdas: [Float] = []

    public func Initialize(substepTime _: Float) {}

    public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}
    public func Apply(substepTime _: Float) {}

    public func Destroy() {}

    public func SetConstraintCount(constraintCount: Int) {
        m_ConstraintCount = constraintCount
    }

    public func GetConstraintCount() -> Int {
        return m_ConstraintCount
    }

    public static func ApplyPositionDelta(particleIndex _: Int, sorFactor _: Float,
                                          positions _: [float4], deltas _: [float4], counts _: [Int]) {}

    public static func ApplyOrientationDelta(particleIndex _: Int, sorFactor _: Float,
                                             orientations _: [quaternion], deltas _: [quaternion], counts _: [Int]) {}
}
