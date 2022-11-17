//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import "CPxController.h"
#import "CPxControllerDesc.h"
#import "CPxObstacle.h"

@interface CPxControllerManager : NSObject

- (uint32_t)getNbControllers;

- (CPxController *)getController:(uint32_t)index;

- (CPxController *)createController:(CPxControllerDesc *)desc;

- (void)purgeControllers;

- (uint32_t)getNbObstacleContexts;

- (CPxObstacleContext *)getObstacleContext:(uint32_t)index;

- (CPxObstacleContext *)createObstacleContext;

- (void)computeInteractions:(float)elapsedTime;

- (void)setTessellation:(bool)flag :(float)maxEdgeLength;

- (void)setOverlapRecoveryModule:(bool)flag;

- (void)setPreciseSweeps:(bool)flag;

- (void)setPreventVerticalSlidingAgainstCeiling:(bool)flag;

- (void)shiftOrigin:(simd_float3)shift;

@end