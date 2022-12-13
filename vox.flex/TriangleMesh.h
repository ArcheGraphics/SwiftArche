//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import <Metal/Metal.h>

@interface TriangleMesh : NSObject

- (bool)load:(NSString *)filename;

- (void)addPoint:(simd_float3)pt;

- (void)addNormal:(simd_float3)n;

- (void)addUv:(simd_float2)t;

- (void)addPointTriangle:(simd_uint3)newPointIndices;

- (void)addNormalTriangle:(simd_uint3)newNormalIndices;

- (void)addUvTriangle:(simd_uint3)newUvIndices;

- (void)buildBVH:(id<MTLDevice>)device;

-(id<MTLBuffer>) nodeBuffer;

-(id<MTLBuffer>) verticesBuffer;

-(id<MTLBuffer>) normalBuffer;

@end
