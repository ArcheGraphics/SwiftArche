//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "../CPxRigidActor.h"
#import "../CPxConstraint.h"

enum CPxJointActorIndex {
    CPxJointActorIndex_eACTOR0,
    CPxJointActorIndex_eACTOR1,
    CPxJointActorIndex_COUNT
};

@interface CPxJoint : NSObject

- (void)setActors:(CPxRigidActor *_Nullable)actor0 :(CPxRigidActor *_Nullable)actor1;

- (void)setLocalPose:(enum CPxJointActorIndex)actor :(simd_float3)position rotation:(simd_quatf)rotation;

- (void)getLocalPose:(enum CPxJointActorIndex)actor :(simd_float3 *_Nonnull)position rotation:(simd_quatf *_Nonnull)rotation;

- (void)getRelativeTransform:(simd_float3 *_Nonnull)position rotation:(simd_quatf *_Nonnull)rotation;

- (simd_float3)getRelativeLinearVelocity;

- (simd_float3)getRelativeAngularVelocity;

- (void)setBreakForce:(float)force :(float)torque;

- (void)getBreakForce:(float *_Nonnull)force :(float *_Nonnull)torque;

- (void)setConstraintFlag:(enum CPxConstraintFlag)flags :(bool)value;

- (void)setInvMassScale0:(float)invMassScale;

- (float)getInvMassScale0;

- (void)setInvInertiaScale0:(float)invInertiaScale;

- (float)getInvInertiaScale0;

- (void)setInvMassScale1:(float)invMassScale;

- (float)getInvMassScale1;

- (void)setInvInertiaScale1:(float)invInertiaScale;

- (float)getInvInertiaScale1;

- (void)setName:(NSString *_Nonnull)name;

- (CPxConstraint *_Nonnull)getConstraint;


@end
