//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "CPxShape.h"

@interface CPxRigidActor : NSObject

- (bool)attachShapeWithShape:(CPxShape *)shape;

- (void)detachShapeWithShape:(CPxShape *)shape;

- (void)setGlobalPose:(simd_float3)position rotation:(simd_quatf)rotation;

- (void)getGlobalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation;

/// Retrieves the value set with PxSetGroup()
- (uint16_t)getGroup;

/// Sets which collision group this actor is part of
- (void)setGroup:(const uint16_t)collisionGroup;

@end
