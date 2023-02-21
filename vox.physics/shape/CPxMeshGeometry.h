//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxGeometry.h"
#import "CPxPhysics.h"
#import <simd/simd.h>

@interface CPxMeshGeometry : CPxGeometry

- (instancetype _Nonnull)initWithPhysics:(CPxPhysics *_Nonnull)physics;

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(NSArray *_Nonnull)points;

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(NSArray *_Nonnull)points
                 indices:(NSArray *_Nonnull)indices
                isUint16:(bool)isUint16;

- (void)createTriangleMesh:(CPxPhysics *_Nonnull)physics
                    points:(NSArray *_Nonnull)points;

- (void)createTriangleMesh:(CPxPhysics *_Nonnull)physics
                    points:(NSArray *_Nonnull)points
                   indices:(NSArray *_Nonnull)indices
                  isUint16:(bool)isUint16;

- (void)setScaleWith:(float)hx hy:(float)hy hz:(float)hz;

- (void)setCookParameter:(CPxPhysics *_Nonnull)physics
                   value:(uint8_t)value;

@end
