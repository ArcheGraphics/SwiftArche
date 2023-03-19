//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxControllerDesc.h"
#import "CPxObstacle.h"
#import "../CPxRigidDynamic.h"

enum CPxControllerCollisionFlag {
    //!< Character is colliding to the sides.
    eCOLLISION_SIDES = (1 << 0),
    //!< Character has collision above.
    eCOLLISION_UP = (1 << 1),
    //!< Character has collision below.
    eCOLLISION_DOWN = (1 << 2)
};

@interface CPxController : NSObject

- (enum CPxControllerShapeType)getType;

- (uint8_t)move:(simd_float3)disp :(float)minDist :(float)elapsedTime;

- (bool)isSetControllerCollisionFlag:(uint8_t)flags :(enum CPxControllerCollisionFlag)flag;

- (bool)setPosition:(simd_float3)position;

- (simd_float3)getPosition;

- (void)setFootPosition:(simd_float3)position;

- (simd_float3)getFootPosition;

- (void)setStepOffset:(float)offset;

- (float)getStepOffset;

- (void)setNonWalkableMode:(enum CPxControllerNonWalkableMode)flag;

- (enum CPxControllerNonWalkableMode)getNonWalkableMode;

- (float)getContactOffset;

- (void)setContactOffset:(float)offset;

- (simd_float3)getUpDirection;

- (void)setUpDirection:(simd_float3)up;

- (float)getSlopeLimit;

- (void)setSlopeLimit:(float)slopeLimit;

- (void)invalidateCache;

- (void)resize:(float)height;

- (void)setUUID:(uint32_t)uuid;

- (uint32_t)collisionFlags;

@end
