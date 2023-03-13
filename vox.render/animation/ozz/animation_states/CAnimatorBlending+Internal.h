//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "../CAnimationState+Internal.h"

@interface CAnimatorBlending ()

- (void)loadSkeleton:(ozz::animation::Skeleton *_Nonnull)skeleton;

- (ozz::vector<ozz::math::SoaTransform> *_Nonnull)locals;

@end