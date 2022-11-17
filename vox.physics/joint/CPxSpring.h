//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

@interface CPxSpring : NSObject
//!< the spring strength of the drive: that is, the force proportional to the position error
@property(nonatomic, assign) float stiffness;
//!< the damping strength of the drive: that is, the force proportional to the velocity error
@property(nonatomic, assign) float damping;

- (instancetype)initWithStiffness:(float)stiffness_ :(float)damping_;

@end