//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

/// Enum to index the members of the EncodeArguments argument buffer.
typedef enum EncodeArgsIndex {
    EncodeArgsIndexCommandBuffer,
    EncodeArgsIndexCommandBufferDepthOnly,
    EncodeArgsIndexIndexBuffer,
    EncodeArgsIndexVertexBuffer,
    EncodeArgsIndexVertexNormalBuffer,
    EncodeArgsIndexVertexTangentBuffer,
    EncodeArgsIndexUVBuffer,
    EncodeArgsIndexFrameDataBuffer,
    EncodeArgsIndexGlobalTexturesBuffer,
    EncodeArgsIndexLightParamsBuffer,
} EncodeArgsIndex;

/// Results of the culling operation.
typedef enum CullResult {
    CullResultNotCulled                 = 0,
    CullResultFrustumCulled             = 1,
    CullResultOcclusionCulled           = 2,
} CullResult;

#define CULLING_THREADGROUP_SIZE  (128)

// Parameters for the culling process.
typedef struct CullParams {
    /// The number of chunks to process.
    uint numChunks;
    /// The offset for writing the chunks.  Allows thread relative indexing
    /// which shaders can reuse between opaque and alpha mask.
    uint offset;
} CullParams;

/// Chunk visualization data.
///  Populated by culling to be applied during rendering.
typedef struct ChunkVizData {
    /// Index for chunk - can be used for coloring.
    uint index;
    /// Type of culling for this chunk - CullResult.
    uint cullType;
    /// Number of overlapping cascades.
    uint cascadeCount;
} ChunkVizData;

