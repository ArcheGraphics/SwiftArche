//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxController.h"
#import "CPxCapsuleControllerDesc.h"

@interface CPxCapsuleController : CPxController

- (float)getRadius;

- (bool)setRadius:(float)radius;

- (float)getHeight;

- (bool)setHeight:(float)height;

- (enum CPxCapsuleClimbingMode)getClimbingMode;

- (bool)setClimbingMode:(enum CPxCapsuleClimbingMode)mode;

@end