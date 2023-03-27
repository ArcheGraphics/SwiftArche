//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Metal/Metal.h>

/// Aligns a value to the next multiple of the alignment.
NSUInteger alignUp(const NSUInteger value, const NSUInteger alignment);

/// Divides a value, rounding up.
NSUInteger divideRoundUp(const NSUInteger &numerator, const NSUInteger &denominator);

MTLSize divideRoundUp(const MTLSize &numerator, const MTLSize &denominator);
