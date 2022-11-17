//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "CPxSpring.h"
#import "CPxTolerancesScale.h"

@interface CPxJointLinearLimitPair : NSObject

- (instancetype)initWithHardLimit:(struct CPxTolerancesScale)scale :(float)lowerLimit :(float)upperLimit :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)lowerLimit :(float)upperLimit :(CPxSpring *)spring;

@end