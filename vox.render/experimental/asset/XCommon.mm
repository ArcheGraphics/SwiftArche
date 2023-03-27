//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "XCommon.h"

NSUInteger alignUp(const NSUInteger value, const NSUInteger alignment) {
    return (value + (alignment - 1)) & ~(alignment - 1);
}

NSUInteger divideRoundUp(const NSUInteger &numerator, const NSUInteger &denominator) {
    // Will break when `numerator+denominator > uint_max`.
    assert(numerator <= UINT32_MAX - denominator);

    return (numerator + denominator - 1) / denominator;
}

MTLSize divideRoundUp(const MTLSize &numerator, const MTLSize &denominator) {
    return (MTLSize)
            {
                    divideRoundUp(numerator.width, denominator.width),
                    divideRoundUp(numerator.height, denominator.height),
                    divideRoundUp(numerator.depth, denominator.depth)
            };
}
