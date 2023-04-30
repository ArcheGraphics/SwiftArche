//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BatchData {
    /// Batch identifier. All bits will be '0', except for the one at the position of the batch./
    public var batchID: UInt16
    /// first constraint in the batch/
    public var startIndex: Int
    /// amount of constraints in the batch./
    public var constraintCount: Int
    /// auxiliar counter used to sort the constraints in linear time./
    public var activeConstraintCount: Int

    /// size of each work item./
    public var workItemSize: Int
    /// number of work items./
    public var workItemCount: Int
    public var isLast: Bool

    public init(index: Int, maxBatches: Int) {
        batchID = UInt16(1 << index)
        isLast = index == (maxBatches - 1)
        constraintCount = 0
        activeConstraintCount = 0

        startIndex = 0
        workItemSize = 0
        workItemCount = 0
    }

    public func GetConstraintRange(workItemIndex: Int, start: inout Int, end: inout Int) {
        start = startIndex + workItemSize * workItemIndex
        end = startIndex + min(constraintCount, workItemSize * (workItemIndex + 1))
    }
}

public struct WorkItem {
    public let minWorkItemSize = 64
    public var constraints = [Int](repeating: 0, count: 64)
    public var constraintCount: Int

    public mutating func Add(constraintIndex: Int) -> Bool {
        // add the constraint to this work item.
        constraints[constraintCount] = constraintIndex

        // if we've completed the work item, close it and reuse for the next one.
        constraintCount += 1
        return constraintCount == minWorkItemSize
    }
}

public struct ConstraintBatcher<T> where T: IConstraintProvider {
    public var maxBatches: Int
    /// look up table for batch indices./
    private var batchLUT: BatchLUT

    public init(maxBatches: Int) {
        self.maxBatches = min(17, maxBatches)
        batchLUT = BatchLUT(numBatches: maxBatches)
    }

    /// Linear-time graph coloring using bitmasks and a look-up table. Used to organize contacts into batches for parallel processing.
    /// input: array of unsorted constraints.
    /// - Parameters:
    ///   - particleCount: sorted constraint indices array.
    ///   - batchData: array of batchData, one per batch: startIndex, batchSize, workItemSize (at most == batchSize), numWorkItems
    ///   - activeBatchCount: number of active batches.
    public func BatchConstraints(constraintDesc _: T,
                                 particleCount _: Int,
                                 batchData _: [BatchData],
                                 activeBatchCount _: [Int]) {}

    private struct BatchContactsJob {
        public var batchMasks: [UInt16]

        public var batchIndices: [Int]

        public private(set) var lut: BatchLUT
        public var constraintDesc: T
        public var batchData: [BatchData]
        public var activeBatchCount: [Int]

        public var maxBatches: Int

        public func Execute() {}
    }
}
