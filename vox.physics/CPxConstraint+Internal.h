//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxConstraint ()

@property(nonatomic, readonly) PxConstraint *c_constraint;

- (instancetype)initWithConstraint:(PxConstraint *)constraint;

@end