//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxGeometry.h"
#import "../CPxPhysics.h"
#import <simd/simd.h>

@interface CPxMeshGeometry : CPxGeometry

- (instancetype _Nonnull)initWith:(CPxPhysics *_Nonnull)physics;

- (void)createMesh:(CPxPhysics *_Nonnull)physics
            points:(void *_Nonnull)points
       pointsCount:(uint32_t)pointsCount
           indices:(void *_Nullable)indices
      indicesCount:(uint32_t)indicesCount
          isUint16:(bool)isUint16
          isConvex:(bool)isConvex;

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(simd_float3 *_Nonnull)points
             pointsCount:(uint32_t)pointsCount
               triangles:(simd_uint3 *_Nullable)triangles
           triangleCount:(uint32_t)triangleCount
                  center:(simd_float3)center;

- (void)setScaleWith:(float)hx hy:(float)hy hz:(float)hz;

- (void)setCookParameter:(CPxPhysics *_Nonnull)physics
                   value:(uint8_t)value;

- (uint32_t)positionCount;

- (void)getPosition:(simd_float3 *_Nonnull)points;

- (uint32_t)indicesCount;

- (void)getWireframeIndices:(uint32_t *_Nonnull)indices;

@end
