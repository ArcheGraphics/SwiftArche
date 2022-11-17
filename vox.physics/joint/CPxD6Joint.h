//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxJoint.h"
#import "CPxD6JointDrive.h"
#import "CPxJointLimitCone.h"
#import "CPxJointLinearLimit.h"
#import "CPxJointLinearLimitPair.h"
#import "CPxJointAngularLimitPair.h"
#import "CPxJointLimitPyramid.h"

enum CPxD6Axis {
    CPxD6Axis_eX = 0,    //!< motion along the X axis
    CPxD6Axis_eY = 1,    //!< motion along the Y axis
    CPxD6Axis_eZ = 2,    //!< motion along the Z axis
    CPxD6Axis_eTWIST = 3,    //!< motion around the X axis
    CPxD6Axis_eSWING1 = 4,    //!< motion around the Y axis
    CPxD6Axis_eSWING2 = 5,    //!< motion around the Z axis
    CPxD6Axis_eCOUNT = 6
};

enum CPxD6Motion {
    CPxD6Motion_eLOCKED,    //!< The DOF is locked, it does not allow relative motion.
    CPxD6Motion_eLIMITED,    //!< The DOF is limited, it only allows motion within a specific range.
    CPxD6Motion_eFREE        //!< The DOF is free and has its full range of motion.
};

enum CPxD6Drive {
    CPxD6Drive_eX = 0,    //!< drive along the X-axis
    CPxD6Drive_eY = 1,    //!< drive along the Y-axis
    CPxD6Drive_eZ = 2,    //!< drive along the Z-axis
    CPxD6Drive_eSWING = 3,    //!< drive of displacement from the X-axis
    CPxD6Drive_eTWIST = 4,    //!< drive of the displacement around the X-axis
    CPxD6Drive_eSLERP = 5,    //!< drive of all three angular degrees along a SLERP-path
    CPxD6Drive_eCOUNT = 6
};

enum CPxD6JointDriveFlag {
    CPxD6JointDriveFlag_eACCELERATION = 1    //!< drive spring is for the acceleration at the joint (rather than the force)
};

@interface CPxD6Joint : CPxJoint

- (void)setMotion:(enum CPxD6Axis)axis :(enum CPxD6Motion)type;

- (enum CPxD6Motion)getMotion:(enum CPxD6Axis)axis;

- (float)getTwistAngle;

- (float)getSwingYAngle;

- (float)getSwingZAngle;

- (void)setDistanceLimit:(CPxJointLinearLimit *)limit;

- (CPxJointLinearLimit *)getDistanceLimit;

- (void)setLinearLimit:(enum CPxD6Axis)axis :(CPxJointLinearLimitPair *)limit;

- (CPxJointLinearLimitPair *)getLinearLimit:(enum CPxD6Axis)axis;

- (void)setTwistLimit:(CPxJointAngularLimitPair *)limit;

- (CPxJointAngularLimitPair *)getTwistLimit;

- (void)setSwingLimit:(CPxJointLimitCone *)limit;

- (CPxJointLimitCone *)getSwingLimit;

- (void)setPyramidSwingLimit:(CPxJointLimitPyramid *)limit;

- (CPxJointLimitPyramid *)getPyramidSwingLimit;

- (void)setDrive:(enum CPxD6Drive)index :(CPxD6JointDrive *)drive;

- (CPxD6JointDrive *)getDrive:(enum CPxD6Drive)index;

- (void)setDrivePosition:(simd_float3)position rotation:(simd_quatf)rotation;

- (void)getDrivePosition:(simd_float3 *)position rotation:(simd_quatf *)rotation;

- (void)setDriveVelocity:(simd_float3)linear :(simd_float3)angular;

- (void)getDriveVelocity:(simd_float3 *)linear :(simd_float3 *)angular;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end