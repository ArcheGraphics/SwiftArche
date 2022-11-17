//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxSpring ()

@property(nonatomic, assign) PxSpring *c_spring;

- (instancetype)initWithSpring:(PxSpring)c_spring;

- (instancetype)initWithD6:(PxD6JointDrive)c_d6;

@end