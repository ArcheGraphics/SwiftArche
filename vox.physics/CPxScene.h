//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "CPxRigidActor.h"
#import "characterkinematic/CPxControllerManager.h"

@interface CPxScene : NSObject

- (void)setGravity:(simd_float3)vec;

- (void)simulate:(float)elapsedTime;

- (bool)fetchResults:(bool)block;

- (void)addActorWith:(CPxRigidActor *_Nonnull)actor;

- (void)removeActorWith:(CPxRigidActor *_Nonnull)actor;

- (bool)raycastSingleWith:(simd_float3)origin
                  unitDir:(simd_float3)unitDir
                 distance:(float)distance
              outPosition:(simd_float3 *_Nonnull)outPosition
                outNormal:(simd_float3 *_Nonnull)outNormal
              outDistance:(float *_Nonnull)outDistance
                 outIndex:(uint32_t *_Nonnull)outIndex
           filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (CPxControllerManager *_Nonnull)createControllerManager;

@end
