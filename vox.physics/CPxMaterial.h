//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

@interface CPxMaterial : NSObject

- (void)setDynamicFriction:(float)coef;

- (float)getDynamicFriction;

- (void)setStaticFriction:(float)coef;

- (float)getStaticFriction;

- (void)setRestitution:(float)rest;

- (float)getRestitution;

- (void)setFrictionCombineMode:(int)combMode;

- (int)getFrictionCombineMode;

- (void)setRestitutionCombineMode:(int)combMode;

- (int)getRestitutionCombineMode;

@end