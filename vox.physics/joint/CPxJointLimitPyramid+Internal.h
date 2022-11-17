//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxJointLimitPyramid ()

@property(nonatomic, readonly) PxJointLimitPyramid *c_limit;

- (instancetype)initWithLimit:(PxJointLimitPyramid)c_limit;

@end