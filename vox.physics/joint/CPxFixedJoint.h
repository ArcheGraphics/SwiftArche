//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxJoint.h"

@interface CPxFixedJoint : CPxJoint

- (void)setProjectionLinearTolerance:(float)tolerance;

- (float)getProjectionLinearTolerance;

- (void)setProjectionAngularTolerance:(float)tolerance;

- (float)getProjectionAngularTolerance;

@end