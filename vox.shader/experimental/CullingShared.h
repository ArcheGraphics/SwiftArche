//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

// Enum to index the members of the XEncodeArguments argument buffer.
typedef enum XEncodeArgsIndex {
    XEncodeArgsIndexCommandBuffer,
    XEncodeArgsIndexCommandBufferDepthOnly,
    XEncodeArgsIndexIndexBuffer,
    XEncodeArgsIndexVertexBuffer,
    XEncodeArgsIndexVertexNormalBuffer,
    XEncodeArgsIndexVertexTangentBuffer,
    XEncodeArgsIndexUVBuffer,
    XEncodeArgsIndexFrameDataBuffer,
    XEncodeArgsIndexGlobalTexturesBuffer,
    XEncodeArgsIndexLightParamsBuffer,
} XEncodeArgsIndex;

// Results of the culling operation.
typedef enum XCullResult {
    XCullResultNotCulled = 0,
    XCullResultFrustumCulled = 1,
    XCullResultOcclusionCulled = 2,
} XCullResult;

#define CULLING_THREADGROUP_SIZE  (128)

// Parameters for the culling process.
typedef struct XCullParams {
    uint numChunks;         // The number of chunks to process.
    uint offset;            // The offset for writing the chunks.  Allows thread relative indexing
    // which shaders can reuse between opaque and alpha mask.
} XCullParams;

// Chunk visualization data.
//  Populated by culling to be applied during rendering.
typedef struct XChunkVizData {
    uint index;         // Index for chunk - can be used for coloring.
    uint cullType;      // Type of culling for this chunk - XCullResult.
    uint cascadeCount;  // Number of overlapping cascades.
} XChunkVizData;

