//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxGeometry.h"
#import <simd/simd.h>

@interface CPxCapsuleGeometry : CPxGeometry

@property(nonatomic, assign) float radius;
@property(nonatomic, assign) float halfHeight;

- (instancetype)initWithRadius:(float)radius halfHeight:(float)halfHeight;

@end