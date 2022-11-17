//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxSphericalJoint.h"
#import "CPxJoint+Internal.h"
#import "CPxJointLimitCone+Internal.h"

@implementation CPxSphericalJoint

- (CPxJointLimitCone *)getLimitCone {
    return [[CPxJointLimitCone alloc] initWithLimit:static_cast<PxSphericalJoint *>(super.c_joint)->getLimitCone()];
}

- (void)setLimitCone:(CPxJointLimitCone *)limit {
    static_cast<PxSphericalJoint *>(super.c_joint)->setLimitCone(*limit.c_limit);
}

- (float)getSwingYAngle {
    return static_cast<PxSphericalJoint *>(super.c_joint)->getSwingYAngle();
}

- (float)getSwingZAngle {
    return static_cast<PxSphericalJoint *>(super.c_joint)->getSwingZAngle();
}

- (void)setSphericalJointFlag:(CPxSphericalJointFlag)flag :(bool)value {
    static_cast<PxSphericalJoint *>(super.c_joint)->setSphericalJointFlag(PxSphericalJointFlag::Enum(flag), value);
}

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxSphericalJoint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxSphericalJoint *>(super.c_joint)->getProjectionLinearTolerance();
}

@end
