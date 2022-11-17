//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "CPxSpring.h"

@interface CPxJointLimitPyramid : NSObject

- (instancetype)initWithHardLimit:(float)yLimitAngleMin :(float)yLimitAngleMax :(float)zLimitAngleMin :(float)zLimitAngleMax :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)yLimitAngleMin :(float)yLimitAngleMax :(float)zLimitAngleMin :(float)zLimitAngleMax :(CPxSpring *)spring;

@end