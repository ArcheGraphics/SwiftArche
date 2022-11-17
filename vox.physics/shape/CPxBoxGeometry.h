//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxGeometry.h"
#import <simd/simd.h>

@interface CPxBoxGeometry : CPxGeometry

@property(nonatomic, assign) simd_float3 halfExtents;

- (instancetype)initWithHx:(float)hx hy:(float)hy hz:(float)hz;

@end