//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxPrismaticJoint.h"
#import "CPxJoint+Internal.h"
#import "CPxJointLinearLimitPair+Internal.h"

@implementation CPxPrismaticJoint

- (float)getPosition {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getPosition();
}

- (float)getVelocity {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getVelocity();
}

- (void)setLimit:(CPxJointLinearLimitPair *)limit {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setLimit(*limit.c_limit);
}

- (CPxJointLinearLimitPair *)getLimit {
    return [[CPxJointLinearLimitPair alloc] initWithLimit:static_cast<PxPrismaticJoint *>(super.c_joint)->getLimit()];
}

- (void)setPrismaticJointFlag:(CPxPrismaticJointFlag)flag :(bool)value {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setPrismaticJointFlag(PxPrismaticJointFlag::Enum(flag), value);
}

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getProjectionLinearTolerance();
}

- (void)setProjectionAngularTolerance:(float)tolerance {
    static_cast<PxPrismaticJoint *>(super.c_joint)->setProjectionAngularTolerance(tolerance);
}

- (float)getProjectionAngularTolerance {
    return static_cast<PxPrismaticJoint *>(super.c_joint)->getProjectionAngularTolerance();
}


@end
