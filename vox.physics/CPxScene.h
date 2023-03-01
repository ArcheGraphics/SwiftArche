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
- (bool)raycastSpecificWith:(simd_float3)origin
                    unitDir:(simd_float3)unitDir
                      shape:(CPxShape *_Nonnull)shape
                   distance:(float)distance
                        hit:(LocationHit *_Nonnull)hit;

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
- (bool)sweepSpecificWith:(simd_float3)unitDir
                 distance:(float)distance
                   shape0:(CPxShape *_Nonnull)shape0
                   shape1:(CPxShape *_Nonnull)shape1
                      hit:(LocationHit *_Nonnull)hit;

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
- (bool)overlapSpecificWith:(CPxShape *_Nonnull)shape0
                     shape1:(CPxShape *_Nonnull)shape1;

- (bool)overlapAnyWith:(CPxShape *_Nonnull)shape
                origin:(simd_float3)origin
        filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (int)overlapMultipleWith:(CPxShape *_Nonnull)shape
                    origin:(simd_float3)origin
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

//MARK: - Other Query
- (bool)computePenetration:(simd_float3 *_Nonnull)direction
                     depth:(float *_Nonnull)depth
                    shape0:(CPxShape *_Nonnull)shape0
                    shape1:(CPxShape *_Nonnull)shape1;

- (float)closestPoint:(simd_float3)point
                shape:(CPxShape *_Nonnull)shape
               cloest:(simd_float3 *_Nonnull)cloest;

@end
