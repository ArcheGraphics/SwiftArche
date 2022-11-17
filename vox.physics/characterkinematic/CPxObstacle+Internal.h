//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "PxPhysicsAPI.h"

using namespace physx;

@interface CPxBoxObstacle ()

@property(nonatomic, assign) PxBoxObstacle c_obstacle;

- (instancetype)initWithObstacle:(PxBoxObstacle)obstacle;

@end

@interface CPxCapsuleObstacle ()

@property(nonatomic, assign) PxCapsuleObstacle c_obstacle;

- (instancetype)initWithObstacle:(PxCapsuleObstacle)obstacle;

@end

@interface CPxObstacleContext ()

@property(nonatomic, readonly) PxObstacleContext *c_context;

- (instancetype)initWithContext:(PxObstacleContext *)context;

@end