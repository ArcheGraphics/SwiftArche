//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ConstraintSorter<T> where T: IConstraint {
    public struct ConstraintComparer<K> where K: IConstraint {
        // Compares by Height, Length, and Width.
        public func Compare(x: K, y: K) -> Bool {
            return x.GetParticle(at: 1) < y.GetParticle(at: 1)
        }
    }

    /// Performs a single-threaded count sort on the constraints array using the first particle index,
    /// then multiple parallel sorts over slices of the original array sorting by the second particle index.
    public func SortConstraints(particleCount _: Int,
                                constraints _: [T],
                                sortedConstraints _: [T]) {}

    public struct CountSortPerFirstParticleJob {
        public var input: [T]
        public var output: [T]

        public var digitCount: [Int]

        public var maxDigits: Int
        public var maxIndex: Int

        public func Execute() {}
    }

    /// Sorts slices of an array in parallel
    public struct SortSubArraysJob {
        public var InOutArray: [Int]

        /// Typically lastDigitIndex is resulting RadixSortPerBodyAJob.digitCount.
        /// nextElementIndex[i] = index of first element with bodyA index == i + 1
        public var NextElementIndex: [Int]

        public var comparer: ConstraintComparer<T>

        public func Execute(workItemIndex _: Int) {}

        public static func DefaultSortOfSubArrays(inOutArray _: [T], startIndex _: Int,
                                                  length _: Int, comparer _: ConstraintComparer<T>) {}
    }
}
