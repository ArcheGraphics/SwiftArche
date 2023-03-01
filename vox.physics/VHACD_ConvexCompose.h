//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>
#import <Foundation/Foundation.h>

/**
* This enumeration determines how the voxels as filled to create a solid
* object. The default should be 'FLOOD_FILL' which generally works fine
* for closed meshes. However, if the mesh is not watertight, then using
* RAYCAST_FILL may be preferable as it will determine if a voxel is part
* of the interior of the source mesh by raycasting around it.
*
* Finally, there are some cases where you might actually want a convex
* decomposition to treat the source mesh as being hollow. If that is the
* case you can pass in 'SURFACE_ONLY' and then the convex decomposition
* will converge only onto the 'skin' of the surface mesh.
*/
enum VHACD_FillMode {
    FLOOD_FILL, // This is the default behavior, after the voxelization step it uses a flood fill to determine 'inside'
    // from 'outside'. However, meshes with holes can fail and create hollow results.
    SURFACE_ONLY, // Only consider the 'surface', will create 'skins' with hollow centers.
    RAYCAST_FILL, // Uses raycasting to determine inside from outside.
};

@interface VHACD_ConvexCompose : NSObject

- (void)computeWithPoints:(float *_Nonnull)points
              pointsCount:(uint32_t)pointsCount
                  indices:(uint32_t *_Nullable)indices
             indicesCount:(uint32_t)indicesCount;

- (uint32_t)hullCount;

- (uint32_t)pointCountAtIndex:(uint32_t)index;

- (uint32_t)triangleCountAtIndex:(uint32_t)index;

- (void)getHullInfoAtIndex:(uint32_t)index
                    points:(simd_float3 *_Nonnull)points
                   indices:(simd_uint3 *_Nullable)indices
                    center:(simd_float3 *_Nonnull)center;

//MARK: - Paramter
/// The maximum number of convex hulls to produce
@property(nonatomic) uint32_t maxConvexHulls;
/// The voxel resolution to use
@property(nonatomic) uint32_t resolution;
/// if the voxels are within 1% of the volume of the hull, we consider this a close enough approximation
@property(nonatomic) double minimumVolumePercentErrorAllowed;
/// The maximum recursion depth
@property(nonatomic) uint32_t maxRecursionDepth;
/// Whether or not to shrinkwrap the voxel positions to the source mesh on output
@property(nonatomic) bool shrinkWrap;
/// How to fill the interior of the voxelized mesh
@property(nonatomic) enum VHACD_FillMode fillMode;
/// The maximum number of vertices allowed in any output convex hull
@property(nonatomic) uint32_t maxNumVerticesPerCH;
/// Whether or not to run asynchronously, taking advantage of additional cores
@property(nonatomic) bool asyncACD;
/// Once a voxel patch has an edge length of less than 4 on all 3 sides, we don't keep recursing
@property(nonatomic) uint32_t minEdgeLength;
/// Whether or not to attempt to split planes along the best location. Experimental feature. False by default.
@property(nonatomic) bool findBestPlane;

@end
