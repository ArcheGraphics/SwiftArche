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

- (CPxRigidDynamic *_Nonnull)getActor;

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

- (void)setQueryFilterData:(uint32_t)w0 w1:(uint32_t)w1 w2:(uint32_t)w2 w3:(uint32_t)w3;

@end