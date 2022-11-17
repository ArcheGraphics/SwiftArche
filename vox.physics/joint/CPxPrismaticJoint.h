//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxJoint.h"
#import "CPxJointLinearLimitPair.h"

enum CPxPrismaticJointFlag {
    CPxPrismaticJointFlag_eLIMIT_ENABLED = 1 << 1
};

@interface CPxPrismaticJoint : CPxJoint

- (float)getPosition;

- (float)getVelocity;

- (void)setLimit:(CPxJointLinearLimitPair *)limit;

- (CPxJointLinearLimitPair *)getLimit;

- (void)setPrismaticJointFlag:(enum CPxPrismaticJointFlag)flag :(bool)value;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end