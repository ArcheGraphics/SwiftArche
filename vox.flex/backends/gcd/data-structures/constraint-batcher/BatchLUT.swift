//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BatchLUT {
    public private(set) var numBatches: Int
    public private(set) var batchIndex: [UInt16]

    public init(numBatches: Int) {
        self.numBatches = numBatches

        batchIndex = [UInt16](repeating: 0, count: Int(UInt16.max) + 1)
        let end = UInt16.max
        let numBits = UInt16(numBatches - 1)

        // For each entry in the table, compute the position of the first '0' bit in the index, starting from the less significant bit.
        // This is the index of the first batch where we can add the constraint to.
        for value in 0 ..< end {
            var valueCopy = value
            for i in 0 ..< numBits {
                if (valueCopy & 1) == 0 {
                    batchIndex[Int(value)] = i
                    break
                }
                valueCopy >>= 1
            }
        }

        batchIndex[Int(end)] = numBits
    }
}
