//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>

/// 3-dimensional floating point bounding box, usable in both Metal Shading Language and C++.
typedef struct {
    simd_float3 min;
    simd_float3 max;
} XBoundingBox3;

/// 3-dimensional floating point sphere, usable in both Metal Shading Language and C++.
typedef struct {
    union {
        /// xy = upper left, zw = lower right; named "data" to force accessor use.
        simd_float4 data;
        simd_float3 center;
        struct {
            float centerxyz[3];
            float radius;
        };
    };
} XSphere;

/// Metadata describing a chunk of an XSubMesh, usable in both metal and C.
struct XMeshChunk {
    /// Sphere that bounds geometry in this chunk.
    XBoundingBox3 boundingBox;
    /// xyz = average angle; w = cos(maxphi)
    simd_float4 normalDistribution;
    /// Only used for debugging the clustering;
    ///   xyz = cluster mean in obj space; w = unused
    simd_float4 clusterMean;
    /// Sphere that bounds geometry in this chunk.
    XSphere boundingSphere;
    /// Index of the material in the materials array for GPU access. Duplicated from XSubMesh.
    uint32_t materialIndex;
    /// Offset in mesh index buffer to the indices for this. chunk.
    unsigned int indexBegin;
    /// Number of indices for this chunk in mesh index buffer.
    unsigned int indexCount;
};

/// A SubMesh represents a group of chunks that share a material.
///  The indices for the chunks in this submesh are contiguous in the index
///  buffer.
struct XSubMesh {
    /// Material index for this submesh.
    uint32_t materialIndex;
    /// Combined bounding box for the chunks in this submesh.
    XBoundingBox3 boundingBox;
    /// Combined bounding sphere for the chunks in this. submesh.
    XSphere boundingSphere;
    /// Offset in mesh index buffer to the indices for this. submesh.
    unsigned int indexBegin;
    /// Number of indices for this submesh in mesh index. buffer.
    unsigned int indexCount;
    /// Offset in mesh index buffer to the chunks for this. submesh.
    unsigned int chunkStart;
    /// Number of chunks for this submesh in mesh index buffer.
    unsigned int chunkCount;
};
