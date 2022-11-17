//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxSpring.h"

@interface CPxD6JointDrive : CPxSpring
//!< the force limit of the drive - may be an impulse or a force depending on PxConstraintFlag::eDRIVE_LIMITS_ARE_FORCES
@property(nonatomic, assign) float forceLimit;
//!< the joint drive flags
@property(nonatomic, assign) uint32_t flags;

- (instancetype)initWithLimitStiffness:(float)driveStiffness :(float)driveDamping :(float)driveForceLimit;

@end