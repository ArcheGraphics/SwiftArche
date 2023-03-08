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
                   position:(simd_float3)position
                   rotation:(simd_quatf)rotation
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
                position0:(simd_float3)position0
                rotation0:(simd_quatf)rotation0
                   shape1:(CPxShape *_Nonnull)shape1
                position1:(simd_float3)position1
                rotation1:(simd_quatf)rotation1
                      hit:(LocationHit *_Nonnull)hit;

- (bool)sweepAnyWith:(CPxShape *_Nonnull)shape
              origin:(simd_float3)origin
            rotation:(simd_quatf)rotation
             unitDir:(simd_float3)unitDir
            distance:(float)distance
      filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (bool)sweepSingleWith:(CPxShape *_Nonnull)shape
                 origin:(simd_float3)origin
               rotation:(simd_quatf)rotation
                unitDir:(simd_float3)unitDir
               distance:(float)distance
                    hit:(LocationHit *_Nonnull)hit
         filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (int)sweepMultipleWith:(CPxShape *_Nonnull)shape
                  origin:(simd_float3)origin
                rotation:(simd_quatf)rotation
                 unitDir:(simd_float3)unitDir
                distance:(float)distance
                     hit:(LocationHit *_Nonnull)hit
                hitCount:(uint32_t)hitCount
          filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

//MARK: - Overlap
- (bool)overlapSpecificWith:(CPxShape *_Nonnull)shape0
                  position0:(simd_float3)position0
                  rotation0:(simd_quatf)rotation0
                     shape1:(CPxShape *_Nonnull)shape1
                  position1:(simd_float3)position1
                  rotation1:(simd_quatf)rotation1;

- (bool)overlapAnyWith:(CPxShape *_Nonnull)shape
                origin:(simd_float3)origin
              rotation:(simd_quatf)rotation
        filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

- (int)overlapMultipleWith:(CPxShape *_Nonnull)shape
                    origin:(simd_float3)origin
                  rotation:(simd_quatf)rotation
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback;

//MARK: - Other Query
- (bool)computePenetration:(simd_float3 *_Nonnull)direction
                     depth:(float *_Nonnull)depth
                    shape0:(CPxShape *_Nonnull)shape0
                 position0:(simd_float3)position0
                 rotation0:(simd_quatf)rotation0
                    shape1:(CPxShape *_Nonnull)shape1
                 position1:(simd_float3)position1
                 rotation1:(simd_quatf)rotation1;

- (float)closestPoint:(simd_float3)point
                shape:(CPxShape *_Nonnull)shape
             position:(simd_float3)position
             rotation:(simd_quatf)rotation
              closest:(simd_float3 *_Nonnull)closest;

// MARK: - Collider Filter
/// Determines if collision detection is performed between a pair of groups
- (bool)getGroupCollisionFlag:(const uint16_t)group1
                       group2:(const uint16_t)group2;

/// Specifies if collision should be performed by a pair of groups
- (void)setGroupCollisionFlag:(const uint16_t)group1
                       group2:(const uint16_t)group2
                       enable:(const bool)enable;

// MARK: - Visualize
@property(nonatomic) float visualScale;

- (void)setVisualType:(uint32_t)type
                value:(bool)value;

- (void)draw:(void (^ _Nullable)(simd_float3 p0, uint32_t color))addPoint
            :(void (^ _Nullable)(uint32_t count))checkResizePoint
            :(void (^ _Nullable)(simd_float3 p0, simd_float3 p1, uint32_t color))addLine
            :(void (^ _Nullable)(uint32_t count))checkResizeLine
            :(void (^ _Nullable)(simd_float3 p0, simd_float3 p1, simd_float3 p2, uint32_t color))addTriangle
            :(void (^ _Nullable)(uint32_t count))checkResizeTriangle;

@end
