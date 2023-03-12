//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CAnimationState.h"
#include <simd/simd.h>

@interface CAnimator : NSObject

+ (int)kMaxJoints;

- (void)update:(float)dt;

- (void)setRootState:(CAnimationState *_Nullable)state;

- (bool)loadSkeleton:(NSString *_Nonnull)filename;

@property(nonatomic) bool localToModelFromExcluded;

@property(nonatomic) int localToModelFrom;

@property(nonatomic) int localToModelTo;

/// Computes the bounding box of _skeleton. This is the box that encloses all skeleton's joints in model space.
- (void)computeSkeletonBounds:(simd_float3 *_Nonnull)min
        :(simd_float3 *_Nonnull)max;

- (uint32_t)findJontIndex:(NSString *_Nonnull)name;

- (simd_float4x4)modelsAt:(uint32_t)index;

- (int)fillPostureUniforms:(float *_Nonnull)uniforms;

// MARK: - IK

@end
