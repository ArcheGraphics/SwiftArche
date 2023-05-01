//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IObiConstraints {
    func GetConstraintType() -> Oni.ConstraintType?

    func GetBatch(at i: Int) -> IObiConstraintsBatch?
    func GetBatchCount() -> Int
    func Clear()

    func AddToSolver(solver: ObiSolver) -> Bool
    func RemoveFromSolver() -> Bool

    func GetConstraintCount() -> Int
    func GetActiveConstraintCount() -> Int
    func DeactivateAllConstraints()

    func Merge(actor: ObiActor, other: IObiConstraints)
}

public class ObiConstraints<T: IObiConstraintsBatch>: IObiConstraints {
    var m_Solver: ObiSolver?
    public var batches: [T] = []

    // merges constraints from a given actor with this one.
    public func Merge(actor _: ObiActor, other _: IObiConstraints) {}

    public func GetConstraintType() -> Oni.ConstraintType? {
        nil
    }

    public func GetBatch(at _: Int) -> IObiConstraintsBatch? {
        nil
    }

    public func GetBatchCount() -> Int {
        0
    }

    public func Clear() {}

    public func AddToSolver(solver _: ObiSolver) -> Bool {
        false
    }

    public func RemoveFromSolver() -> Bool {
        false
    }

    public func GetConstraintCount() -> Int {
        0
    }

    public func GetActiveConstraintCount() -> Int {
        0
    }

    public func DeactivateAllConstraints() {}

    public func CreateBatch(source _: T? = nil) -> T? {
        nil
    }

    public func AddBatch(batch _: T) {}

    public func RemoveBatch(batch _: T) -> Bool {
        false
    }
}
