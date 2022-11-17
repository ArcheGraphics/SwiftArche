//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxJoint.h"

enum CPxDistanceJointFlag {
    CPxDistanceJointFlag_eMAX_DISTANCE_ENABLED = 1 << 1,
    CPxDistanceJointFlag_eMIN_DISTANCE_ENABLED = 1 << 2,
    CPxDistanceJointFlag_eSPRING_ENABLED = 1 << 3
};

@interface CPxDistanceJoint : CPxJoint

- (float)getDistance;

- (void)setMinDistance:(float)distance;

- (float)getMinDistance;

- (void)setMaxDistance:(float)distance;

- (float)getMaxDistance;

- (void)setTolerance:(float)tolerance;

- (float)getTolerance;

- (void)setStiffness:(float)stiffness;

- (float)getStiffness;

- (void)setDamping:(float)damping;

- (float)getDamping;

- (void)setDistanceJointFlag:(enum CPxDistanceJointFlag)flag :(bool)value;

@end