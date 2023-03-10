//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#include <ozz/base/containers/vector.h>
#include <ozz/base/maths/soa_transform.h>

@interface CAnimationState ()

- (ozz::vector<ozz::math::SimdFloat4>)jointMasks;

@end
