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
#import "CPxShape.h"

typedef struct {
    simd_float3 position;
    uint32_t index;
    simd_float3 normal;
    float distance;
} LocationHit;

@interface CPxScene : NSObject

- (void)setGravity:(simd_float3)vec;

- (void)simulate:(float)elapsedTime;

- (bool)fetchResults:(bool)block;

- (void)addActorWith:(CPxRigidActor *_Nonnull)actor;

- (void)removeActorWith:(CPxRigidActor *_Nonnull)actor;

- (CPxControllerManager *_Nonnull)createControllerManager;

// MARK: - Raycast
- (bool)raycastAnyWith:(simd_float3)origin
                  unitDir:(simd_float3)unitDir
                 distance:(float)distance
           filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (bool)raycastSingleWith:(simd_float3)origin
                  unitDir:(simd_float3)unitDir
                 distance:(float)distance
                      hit:(LocationHit *_Nonnull)hit
           filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (int)raycastMultipleWith:(simd_float3)origin
                   unitDir:(simd_float3)unitDir
                  distance:(float)distance
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

// MARK: - Sweep
- (bool)sweepAnyWith:(CPxShape *_Nonnull)shape
                 origin:(simd_float3)origin
                unitDir:(simd_float3)unitDir
               distance:(float)distance
      filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (bool)sweepSingleWith:(CPxShape *_Nonnull)shape
                 origin:(simd_float3)origin
                unitDir:(simd_float3)unitDir
               distance:(float)distance
                    hit:(LocationHit *_Nonnull)hit
         filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (int)sweepMultipleWith:(CPxShape *_Nonnull)shape
                  origin:(simd_float3)origin
                 unitDir:(simd_float3)unitDir
                distance:(float)distance
                     hit:(LocationHit *_Nonnull)hit
                hitCount:(uint32_t)hitCount
          filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

//MARK: - Overlap
- (bool)overlapAnyWith:(CPxShape *_Nonnull)shape
                 origin:(simd_float3)origin
        filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;
    
- (int)overlapMultipleWith:(CPxShape *_Nonnull)shape
                    origin:(simd_float3)origin
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

@end
