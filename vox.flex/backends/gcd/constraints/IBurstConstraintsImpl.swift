//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IBurstConstraintsImpl: IConstraints {
    func Initialize(substepTime: Float)
    func Project(stepTime: Float, substepTime: Float, substeps: Int)

    func CreateConstraintsBatch() -> IConstraintsBatchImpl?
    func RemoveBatch(batch: IConstraintsBatchImpl)
}

public class BurstConstraintsImpl<T: BurstConstraintsBatchImpl>: IBurstConstraintsImpl {
    var m_Solver: BurstSolverImpl
    public var batches: [T] = []

    var m_ConstraintType: Oni.ConstraintType

    public var constraintType: Oni.ConstraintType { return m_ConstraintType }

    public var solver: ISolverImpl { return m_Solver }

    public init(solver: BurstSolverImpl, constraintType: Oni.ConstraintType) {
        m_ConstraintType = constraintType
        m_Solver = solver
    }

    public func CreateConstraintsBatch() -> IConstraintsBatchImpl? {
        nil
    }

    public func RemoveBatch(batch _: IConstraintsBatchImpl) {}

    public func GetConstraintCount() -> Int {
        0
    }

    public func Initialize(substepTime _: Float) {}

    public func Project(stepTime _: Float, substepTime _: Float, substeps _: Int) {}
}
