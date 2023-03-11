//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#include <ozz/base/containers/vector.h>
#include <ozz/base/maths/soa_transform.h>
#include <ozz/animation/runtime/skeleton.h>

@interface CAnimationState ()

@property(nonatomic) ozz::vector<CAnimationState *_Nonnull> states;

- (ozz::vector<ozz::math::SimdFloat4>)jointMasks;

- (void)loadSkeleton:(ozz::animation::Skeleton *_Nonnull)skeleton;

- (ozz::vector<ozz::math::SoaTransform> *_Nonnull)locals;

@end
