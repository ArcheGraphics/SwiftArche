//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IObiConstraintsBatch {
    var constraintCount: Int {
        get
    }

    var activeConstraintCount: Int {
        get
        set
    }

    var initialActiveConstraintCount: Int {
        get
        set
    }

    var constraintType: Oni.ConstraintType! {
        get
    }

    var implementation: IConstraintsBatchImpl! {
        get
    }

    func AddToSolver(solver: ObiSolver)
    func RemoveFromSolver(solver: ObiSolver)

    func Merge(actor: ObiActor, other: IObiConstraintsBatch)

    func DeactivateConstraint(at constraintIndex: Int) -> Bool
    func ActivateConstraint(at constraintIndex: Int) -> Bool
    func DeactivateAllConstraints()

    func Clear()

    func GetParticlesInvolved(at index: Int, particles: [Int])
    func ParticlesSwapped(at index: Int, newIndex: Int)
}

public class ObiConstraintsBatch: IObiConstraintsBatch {
    var m_IDs: [Int] = []
    /// maps from constraint ID to constraint index. When activating/deactivating constraints, their order changes. That makes this
    /// map necessary. All active constraints are at the beginning of the constraint arrays, in the 0, activeConstraintCount index range.
    var m_IDToIndex: [Int] = []

    var m_ConstraintCount = 0
    var m_ActiveConstraintCount = 0
    var m_InitialActiveConstraintCount = 0

    /// particle indices, amount of them per constraint can be variable.
    public var particleIndices: [Int] = []
    /// constraint lambdas
    public var lambdas: [Float] = []

    public var constraintCount: Int {
        m_ConstraintCount
    }

    public var activeConstraintCount: Int {
        get { return m_ActiveConstraintCount }
        set { m_ActiveConstraintCount = newValue }
    }

    public var initialActiveConstraintCount: Int {
        get { return m_InitialActiveConstraintCount }
        set { m_InitialActiveConstraintCount = newValue }
    }

    public var constraintType: Oni.ConstraintType!

    public var implementation: IConstraintsBatchImpl!

    public func AddToSolver(solver _: ObiSolver) {}

    public func RemoveFromSolver(solver _: ObiSolver) {}

    public func Merge(actor _: ObiActor, other _: IObiConstraintsBatch) {}

    public func DeactivateConstraint(at _: Int) -> Bool {
        false
    }

    public func ActivateConstraint(at _: Int) -> Bool {
        false
    }

    public func DeactivateAllConstraints() {}

    public func Clear() {}

    public func GetParticlesInvolved(at _: Int, particles _: [Int]) {}

    public func ParticlesSwapped(at _: Int, newIndex _: Int) {}
}
