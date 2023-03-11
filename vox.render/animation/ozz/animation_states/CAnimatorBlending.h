//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "../CAnimationState.h"

@interface CAnimatorBlending : CAnimationState

@property(nonatomic) float threshold;

- (void)update:(float)dt;

@end
