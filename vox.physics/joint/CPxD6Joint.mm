//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxD6Joint.h"
#import "CPxSpring+Internal.h"
#import "CPxJoint+Internal.h"
#import "CPxJointLimitCone+Internal.h"
#import "CPxJointLinearLimit+Internal.h"
#import "CPxJointLinearLimitPair+Internal.h"
#import "CPxJointAngularLimitPair+Internal.h"
#import "CPxJointLimitPyramid+Internal.h"

@implementation CPxD6Joint

- (void)setMotion:(enum CPxD6Axis)axis :(enum CPxD6Motion)type {
    static_cast<PxD6Joint *>(super.c_joint)->setMotion(PxD6Axis::Enum(axis), PxD6Motion::Enum(type));
}

- (enum CPxD6Motion)getMotion:(enum CPxD6Axis)axis {
    return CPxD6Motion(static_cast<PxD6Joint *>(super.c_joint)->getMotion(PxD6Axis::Enum(axis)));
}

- (float)getTwistAngle {
    return static_cast<PxD6Joint *>(super.c_joint)->getTwistAngle();
}

- (float)getSwingYAngle {
    return static_cast<PxD6Joint *>(super.c_joint)->getSwingYAngle();
}

- (float)getSwingZAngle {
    return static_cast<PxD6Joint *>(super.c_joint)->getSwingZAngle();
}

- (void)setDistanceLimit:(CPxJointLinearLimit *)limit {
    static_cast<PxD6Joint *>(super.c_joint)->setDistanceLimit(*limit.c_limit);
}

- (CPxJointLinearLimit *)getDistanceLimit {
    return [[CPxJointLinearLimit alloc] initWithLimit:static_cast<PxD6Joint *>(super.c_joint)->getDistanceLimit()];
}

- (void)setLinearLimit:(enum CPxD6Axis)axis :(CPxJointLinearLimitPair *)limit {
    static_cast<PxD6Joint *>(super.c_joint)->setLinearLimit(PxD6Axis::Enum(axis), *limit.c_limit);
}

- (CPxJointLinearLimitPair *)getLinearLimit:(enum CPxD6Axis)axis {
    return [[CPxJointLinearLimitPair alloc] initWithLimit:static_cast<PxD6Joint *>(super.c_joint)->getLinearLimit(PxD6Axis::Enum(axis))];
}

- (void)setTwistLimit:(CPxJointAngularLimitPair *)limit {
    static_cast<PxD6Joint *>(super.c_joint)->setTwistLimit(*limit.c_limit);
}

- (CPxJointAngularLimitPair *)getTwistLimit {
    return [[CPxJointAngularLimitPair alloc] initWithLimit:static_cast<PxD6Joint *>(super.c_joint)->getTwistLimit()];
}

- (void)setSwingLimit:(CPxJointLimitCone *)limit {
    static_cast<PxD6Joint *>(super.c_joint)->setSwingLimit(*limit.c_limit);
}

- (CPxJointLimitCone *)getSwingLimit {
    return [[CPxJointLimitCone alloc] initWithLimit:static_cast<PxD6Joint *>(super.c_joint)->getSwingLimit()];
}

- (void)setPyramidSwingLimit:(CPxJointLimitPyramid *)limit {
    static_cast<PxD6Joint *>(super.c_joint)->setPyramidSwingLimit(*limit.c_limit);
}

- (CPxJointLimitPyramid *)getPyramidSwingLimit {
    return [[CPxJointLimitPyramid alloc] initWithLimit:static_cast<PxD6Joint *>(super.c_joint)->getPyramidSwingLimit()];
}

- (void)setDrive:(enum CPxD6Drive)index :(CPxD6JointDrive *)drive {
    static_cast<PxD6Joint *>(super.c_joint)->setDrive(PxD6Drive::Enum(index), *static_cast<PxD6JointDrive *>(drive.c_spring));
}

- (CPxD6JointDrive *)getDrive:(CPxD6Drive)index {
    return [[CPxD6JointDrive alloc] initWithD6:static_cast<PxD6Joint *>(super.c_joint)->getDrive(PxD6Drive::Enum(index))];
}

- (void)setDrivePosition:(simd_float3)position rotation:(simd_quatf)rotation {
    static_cast<PxD6Joint *>(super.c_joint)->setDrivePosition(PxTransform(PxVec3(position.x, position.y, position.z),
            PxQuat(rotation.vector.x, rotation.vector.y,
                    rotation.vector.z, rotation.vector.w)));
}

- (void)getDrivePosition:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = static_cast<PxD6Joint *>(super.c_joint)->getDrivePosition();
    *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
    *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
}

- (void)setDriveVelocity:(simd_float3)linear :(simd_float3)angular {
    static_cast<PxD6Joint *>(super.c_joint)->setDriveVelocity(PxVec3(linear.x, linear.y, linear.z), PxVec3(angular.x, angular.y, angular.z));
}

- (void)getDriveVelocity:(simd_float3 *)linear :(simd_float3 *)angular {
    PxVec3 plinear;
    PxVec3 panguler;
    static_cast<PxD6Joint *>(super.c_joint)->getDriveVelocity(plinear, panguler);
    *linear = simd_make_float3(plinear.x, plinear.y, plinear.z);
    *angular = simd_make_float3(panguler.x, panguler.y, panguler.z);
}

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxD6Joint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxD6Joint *>(super.c_joint)->getProjectionLinearTolerance();
}

- (void)setProjectionAngularTolerance:(float)tolerance {
    static_cast<PxD6Joint *>(super.c_joint)->setProjectionAngularTolerance(tolerance);
}

- (float)getProjectionAngularTolerance {
    return static_cast<PxD6Joint *>(super.c_joint)->getProjectionAngularTolerance();
}

@end
