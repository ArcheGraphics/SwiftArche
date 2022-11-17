//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxJoint.h"
#import "CPxJointLimitCone.h"

enum CPxSphericalJointFlag {
    //!< the cone limit for the spherical joint is enabled
    CPxSphericalJointFlag_eLIMIT_ENABLED = 1 << 1
};

@interface CPxSphericalJoint : CPxJoint
- (CPxJointLimitCone *)getLimitCone;

- (void)setLimitCone:(CPxJointLimitCone *)limit;

- (float)getSwingYAngle;

- (float)getSwingZAngle;

- (void)setSphericalJointFlag:(enum CPxSphericalJointFlag)flag :(bool)value;

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

@end