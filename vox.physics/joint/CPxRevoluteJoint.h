//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxJoint.h"
#import "CPxJointAngularLimitPair.h"

enum CPxRevoluteJointFlag {
    //!< enable the limit
    CPxRevoluteJointFlag_eLIMIT_ENABLED = 1 << 0,
    //!< enable the drive
    CPxRevoluteJointFlag_eDRIVE_ENABLED = 1 << 1,
    //!< if the existing velocity is beyond the drive velocity, do not add force
    CPxRevoluteJointFlag_eDRIVE_FREESPIN = 1 << 2
};

@interface CPxRevoluteJoint : CPxJoint

- (float)getAngle;

- (float)getVelocity;

- (void)setLimit:(CPxJointAngularLimitPair *)limits;

- (CPxJointAngularLimitPair *)getLimit;

- (void)setDriveVelocity:(float)velocity;

- (float)getDriveVelocity;

- (void)setDriveForceLimit:(float)limit;

- (float)getDriveForceLimit;

- (void)setDriveGearRatio:(float)ratio;

- (float)getDriveGearRatio;

- (void)setRevoluteJointFlag:(enum CPxRevoluteJointFlag)flag :(bool)value;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end