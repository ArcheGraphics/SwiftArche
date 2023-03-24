//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "ShaderCommon.h"
#import "CullingShared.h"

// Toggled to enable/disable occlusion culling.
constant bool gUseOcclusionCulling  [[function_constant(XFunctionConstIndexUseOcclusionCulling)]];

// Toggled for objects with alpha mask during depth only render command encoding.
constant bool gUseAlphaMask         [[function_constant(XFunctionConstIndexEncodeAlphaMask)]];

// Toggled for encoding depth only render pass render commands.
constant bool gEncodeToDepthOnly    [[function_constant(XFunctionConstIndexEncodeToDepthOnly)]];

// Toggled for encoding main render pass render commands.
constant bool gEncodeToMain         [[function_constant(XFunctionConstIndexEncodeToMain)]];

// Toggled to visualize the results of culling.
constant bool gVisualizeCulling     [[function_constant(XFunctionConstIndexVisualizeCulling)]];

constant bool gUseRasterizationRate [[function_constant(XFunctionConstIndexRasterizationRate)]];

// Flag to indicate that commands should be tightly packed.
// If visualizing culling, all objects need to be rendered.
// If transparent, chunk order needs to be stable
constant bool gPackCommands         [[function_constant(XFunctionConstIndexPackCommands)]];

constant bool gUseFilteredCulling   [[function_constant(XFunctionConstIndexFilteredCulling)]];

// Structure containing all of the arguments for encoding commands.
struct XEncodeArguments
{
    command_buffer cmdBuffer                            [[ id(XEncodeArgsIndexCommandBuffer) ]];
    command_buffer cmdBufferDepthOnly                   [[ id(XEncodeArgsIndexCommandBufferDepthOnly) ]];
    const device uint *indexBuffer                      [[ id(XEncodeArgsIndexIndexBuffer) ]];
    device packed_float3 *vertexBuffer                  [[ id(XEncodeArgsIndexVertexBuffer) ]];
    device packed_float3 *vertexNormalBuffer            [[ id(XEncodeArgsIndexVertexNormalBuffer) ]];
    device packed_float3 *vertexTangentBuffer           [[ id(XEncodeArgsIndexVertexTangentBuffer) ]];
    device float2 *uvBuffer                             [[ id(XEncodeArgsIndexUVBuffer) ]];
    constant XFrameConstants *frameDataBuffer        [[ id(XEncodeArgsIndexFrameDataBuffer) ]];
    constant XGlobalTextures *globalTexturesBuffer   [[ id(XEncodeArgsIndexGlobalTexturesBuffer) ]];
    constant XShaderLightParams *lightParamsBuffer   [[ id(XEncodeArgsIndexLightParamsBuffer) ]];
};

//------------------------------------------------------------------------------

// Checks if a sphere is in a frustum.
static bool sphereInFrustum(constant XCameraParams & cameraParams, const XSphere sphere)
{
    return (min(
                min(sphere.distanceToPlane(cameraParams.worldFrustumPlanes[0]),
                    min(sphere.distanceToPlane(cameraParams.worldFrustumPlanes[1]),
                        sphere.distanceToPlane(cameraParams.worldFrustumPlanes[2]))),
                min(sphere.distanceToPlane(cameraParams.worldFrustumPlanes[3]),
                    min(sphere.distanceToPlane(cameraParams.worldFrustumPlanes[4]),
                        sphere.distanceToPlane(cameraParams.worldFrustumPlanes[5]))))) >= 0.0f;
}

// Generates an outcode for a clip space vertex.
uint outcode(float4 f)
{
    return
        (( f.x > f.w) << 0) |
        (( f.y > f.w) << 1) |
        (( f.z > f.w) << 2) |
        ((-f.x > f.w) << 3) |
        ((-f.y > f.w) << 4) |
        ((-f.z > f.w) << 5);
}

// Checks if a chunk is offscreen or occluded based on frustum and depth
//  culling.
static bool chunkOccluded(constant XFrameConstants & frameData,
                          constant XCameraParams & cameraParams,
                          constant rasterization_rate_map_data * rrData,
                          texture2d<float> depthPyramid,
                          const device XMeshChunk &chunk)
{
    const XBoundingBox3 worldBoundingBox = chunk.boundingBox;

    XBoundingBox3 projBounds = XBoundingBox3::sEmpty();

    // Frustum culling
    uint flags = 0xFF;
    for (uint i = 0; i < 8; ++i)
    {
        float4 f = cameraParams.viewProjectionMatrix * float4(worldBoundingBox.GetCorner(i), 1.0f);

        flags &= outcode(f);

        // prevent issues with corners behind camera
        f.z = max(f.z, 0.0f);

        float3 fp = f.xyz / f.w;
        fp.xy = fp.xy * float2(0.5, -0.5) + 0.5;
        fp = saturate(fp);
#if SUPPORT_RASTERIZATION_RATE
        if (gUseRasterizationRate)
        {
            rasterization_rate_map_decoder decoder(*rrData);
            fp.xy = decoder.map_screen_to_physical_coordinates(fp.xy * frameData.screenSize) * frameData.invPhysicalSize;
        }
#endif

        projBounds.Encapsulate(fp);
    }

    if (flags)
        return true;

    /*
    // Contribution culling
    float area = (projBounds.max.x - projBounds.min.x) * (projBounds.max.y - projBounds.min.y);

    if(area < 0.00001f)
        return true;
    */

    // Depth buffer culling.
    const uint2 texSize = uint2(depthPyramid.get_width(), depthPyramid.get_height());

    const float2 projExtent = float2(texSize) * (projBounds.max.xy - projBounds.min.xy);
    const uint lod = ceil(log2(max(projExtent.x, projExtent.y)));

    constexpr sampler pyramidGatherSampler(filter::nearest, mip_filter::nearest, address::clamp_to_edge);
    const uint2 lodSizeInLod0Pixels = texSize & (0xFFFFFFFF << lod);
    const float2 lodScale = float2(texSize) / float2(lodSizeInLod0Pixels);
    const float2 sampleLocationMin = projBounds.min.xy * lodScale;
    const float2 sampleLocationMax = projBounds.max.xy * lodScale;

    const float d0 = depthPyramid.sample(pyramidGatherSampler, float2(sampleLocationMin.x, sampleLocationMin.y), level(lod)).x;
    const float d1 = depthPyramid.sample(pyramidGatherSampler, float2(sampleLocationMin.x, sampleLocationMax.y), level(lod)).x;
    const float d2 = depthPyramid.sample(pyramidGatherSampler, float2(sampleLocationMax.x, sampleLocationMin.y), level(lod)).x;
    const float d3 = depthPyramid.sample(pyramidGatherSampler, float2(sampleLocationMax.x, sampleLocationMax.y), level(lod)).x;

    const float compareValue = projBounds.min.z;

    float maxDepth = max(max(d0, d1), max(d2, d3));
    return compareValue >= maxDepth;
}

//------------------------------------------------------------------------------

// Encodes the commands to render a chunk to a render_command.
__attribute__((always_inline))
static void encodeChunkCommand(thread render_command & cmd,
                               constant XCameraParams & cameraParams,
                               constant XEncodeArguments & encodeArgs,
                               const device XShaderMaterial *materialBuffer,
                               uint materialIndex,
                               uint indexBegin,
                               uint indexCount)
{
    cmd.set_vertex_buffer(encodeArgs.frameDataBuffer, XBufferIndexFrameData);
    cmd.set_vertex_buffer(&cameraParams, XBufferIndexCameraParams);
    cmd.set_fragment_buffer(encodeArgs.frameDataBuffer, XBufferIndexFrameData);
    cmd.set_fragment_buffer(&cameraParams, XBufferIndexCameraParams);

    cmd.set_vertex_buffer(encodeArgs.vertexBuffer, XBufferIndexVertexMeshPositions);
    cmd.set_vertex_buffer(encodeArgs.vertexNormalBuffer, XBufferIndexVertexMeshNormals);
    cmd.set_vertex_buffer(encodeArgs.vertexTangentBuffer, XBufferIndexVertexMeshTangents);
    cmd.set_vertex_buffer(encodeArgs.uvBuffer, XBufferIndexVertexMeshGenerics);

    cmd.set_fragment_buffer(encodeArgs.globalTexturesBuffer, XBufferIndexFragmentGlobalTextures);
    cmd.set_fragment_buffer(&materialBuffer[materialIndex], XBufferIndexFragmentMaterial);
    cmd.set_fragment_buffer(encodeArgs.lightParamsBuffer, XBufferIndexFragmentLightParams);

    cmd.draw_indexed_primitives(metal::primitive_type::triangle, indexCount, &encodeArgs.indexBuffer[indexBegin], 1);
}

// Encodes the commands to render a chunk to a render_command, only setting
//  buffers needed for a depth only pass which is quicker than the
//  encodeChunkCommand() function.
__attribute__((always_inline))
static void encodeChunkCommand_DepthOnly(thread render_command & cmd,
                                         constant XCameraParams & cameraParams,
                                         constant XEncodeArguments & encodeArgs,
                                         const device XShaderMaterial *materialBuffer,
                                         uint materialIndex,
                                         uint indexBegin,
                                         uint indexCount)

{
#if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
    if(gUseFilteredCulling)
    {
        // Pass `frameDataBuffer` to allow rendering from all cameras and not just `cameraParams`.
        cmd.set_vertex_buffer(encodeArgs.frameDataBuffer, XBufferIndexFrameData);
    }
#endif
    cmd.set_vertex_buffer(&cameraParams, XBufferIndexCameraParams);
    cmd.set_vertex_buffer(encodeArgs.vertexBuffer, XBufferIndexVertexMeshPositions);

    if(gUseAlphaMask)
    {
        cmd.set_vertex_buffer(encodeArgs.uvBuffer, XBufferIndexVertexMeshGenerics);
        cmd.set_fragment_buffer(&materialBuffer[materialIndex], XBufferIndexFragmentMaterial);
    }

    cmd.draw_indexed_primitives(metal::primitive_type::triangle, indexCount, &encodeArgs.indexBuffer[indexBegin], 1);
}

//------------------------------------------------------------------------------

// Resets the length of a chunk execution range before it can be used as output
//  for encoding non-culled render commands.
kernel void resetChunkExecutionRange(device MTLIndirectCommandBufferExecutionRange & range [[ buffer(XBufferIndexComputeExecutionRange) ]],
                                     constant uint & lengthResetValue [[ buffer(XBufferIndexComputeExecutionRange + 1) ]])
{
    range.location = 0;
    range.length = lengthResetValue;
}

//----------------------------------------------------------

// Encodes a render command to render a chunk without culling.
kernel void encodeChunks(const uint tid                                   [[ thread_position_in_grid ]],
                         constant XCullParams & cullParams             [[ buffer(XBufferIndexCullParams) ]],
                         constant XCameraParams & cameraParams         [[ buffer(XBufferIndexCameraParams) ]],
                         constant XEncodeArguments & encodeArgs        [[ buffer(XBufferIndexComputeEncodeArguments) ]],
                         const device XShaderMaterial * materialBuffer [[ buffer(XBufferIndexComputeMaterial) ]],
                         const device XMeshChunk * chunks              [[ buffer(XBufferIndexComputeChunks) ]])
{
    if (tid >= cullParams.numChunks)
        return;

    const device XMeshChunk &chunk = chunks[tid];

    if(gEncodeToDepthOnly)
    {
        render_command cmd(encodeArgs.cmdBufferDepthOnly, tid);
        encodeChunkCommand_DepthOnly(cmd, cameraParams, encodeArgs, materialBuffer, chunk.materialIndex, chunk.indexBegin, chunk.indexCount);
    }

    if(gEncodeToMain)
    {
        render_command cmd(encodeArgs.cmdBuffer, tid);
        encodeChunkCommand(cmd, cameraParams, encodeArgs, materialBuffer, chunk.materialIndex, chunk.indexBegin, chunk.indexCount);
    }
}

//------------------------------------------------------------------------------

// Encodes a render command to render a chunk with frustum and depth based
//  culling, dependent on function constants.
// Note: Needs to be dispatched with 128 wide threadgroup
kernel void encodeChunksWithCulling(const uint tid                                        [[ thread_position_in_grid ]],
                                    const uint indexInTG                                  [[ thread_index_in_threadgroup ]],
                                    constant XCullParams & cullParams                  [[ buffer(XBufferIndexCullParams) ]],
                                    constant XCameraParams & cullCameraParams          [[ buffer(XBufferIndexComputeCullCameraParams) ]],
                                    constant XCameraParams & cameraParams              [[ buffer(XBufferIndexCameraParams) ]],
                                    constant XEncodeArguments & encodeArgs             [[ buffer(XBufferIndexComputeEncodeArguments) ]],
                                    const device XShaderMaterial * materialBuffer      [[ buffer(XBufferIndexComputeMaterial) ]],
                                    device MTLIndirectCommandBufferExecutionRange & range [[ buffer(XBufferIndexComputeExecutionRange) ]],
                                    const device XMeshChunk * chunks                   [[ buffer(XBufferIndexComputeChunks) ]],
                                    device XChunkVizData * chunkViz                    [[ buffer(XBufferIndexComputeChunkViz), function_constant(gVisualizeCulling) ]],
                                    constant XFrameConstants & frameData               [[ buffer(XBufferIndexComputeFrameData) ]],
                                    constant rasterization_rate_map_data * rrData         [[ buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate) ]],
                                    texture2d<float> depthPyramid                         [[ texture(0), function_constant(gUseOcclusionCulling) ]])
{
    bool validChunk = (tid < cullParams.numChunks);

    if (!gPackCommands && validChunk)
    {
        // reset commands since they're not packed
        render_command cmd(encodeArgs.cmdBuffer, tid);
        cmd.reset();
    }

    threadgroup uint visible[CULLING_THREADGROUP_SIZE];

    // Array of index count to add to the render command from the previous chunk
    threadgroup uint indexCountFollowingPrevious[CULLING_THREADGROUP_SIZE];

    indexCountFollowingPrevious[indexInTG] = 0;
    visible[indexInTG] = 0;

    const device XMeshChunk &chunk = chunks[tid];

    bool occlusionCulled = false;
    bool frustumCulled = false;
    bool culled = false;

    if(validChunk)
    {
        if (!gPackCommands)
        {
            // reset commands since they're not packed
            render_command cmd(encodeArgs.cmdBuffer, tid);
            cmd.reset();
        }
        if(!gVisualizeCulling)
        {
            frustumCulled = !sphereInFrustum(cullCameraParams, chunk.boundingSphere);
        }

        if(!frustumCulled &&                // Chunk not already culled
           gUseOcclusionCulling &&  // Occlusion culling is enabled
           !gVisualizeCulling)      // Not visualizibng culling results
        {
            // Check if chunch is occlusiont cullde
            occlusionCulled = chunkOccluded(frameData,
                                            cullCameraParams,
                                            gUseRasterizationRate ? rrData : nullptr,
                                            depthPyramid, chunk);
        }

        culled = (frustumCulled || occlusionCulled);

        if(!culled)
        {
            visible[indexInTG] = 1;
        }
    }

    threadgroup_barrier(mem_flags::mem_threadgroup);

    if(validChunk)
    {
        if(indexInTG > 0 && !culled)
        {
            const device XMeshChunk &prev = chunks[tid-1];

            bool isContiguousWithPrevious;
            // Previous is also visible and can write this
            isContiguousWithPrevious = visible[indexInTG-1];

            // Share the same material
            isContiguousWithPrevious &= (chunk.materialIndex == prev.materialIndex);

            // Contiguous sets of indices
            isContiguousWithPrevious &= (chunk.indexBegin == (prev.indexBegin + prev.indexCount));

            indexCountFollowingPrevious[indexInTG] = isContiguousWithPrevious ? chunk.indexCount : 0;
        }
    }

    threadgroup_barrier(mem_flags::mem_threadgroup);

    // If a previous thread in the group would have already included this chunk in a draw call it issued
    bool writtenByAPreviousThreadInGroup = indexCountFollowingPrevious[indexInTG];

    if(!validChunk || (!gVisualizeCulling &&
                       (culled || writtenByAPreviousThreadInGroup)))
    {
        return;
    }

    uint indexCount = chunk.indexCount;
    if(!gVisualizeCulling)
    {
        // Check indexCountFollowingPrevious to see  if the index buffer for this chunk is
        // contiguous with the following chunks in this threadgroups.  If they are contiguous and
        // visible then we only need one indexed draw command that draws indices from start of this
        // chunk's indices to the end of last contiguous chunks index.  Here we also sum up the
        // number of indices to draw in our indirect draw call into the indexCount variable.
        for(uint localTGID = indexInTG+1, localTID = tid+1;
            (localTGID < CULLING_THREADGROUP_SIZE) &&  (localTID < cullParams.numChunks);
            localTGID++, localTID++)
        {
            uint extraIndexCount = indexCountFollowingPrevious[localTGID];
            indexCount += extraIndexCount;
            if(!extraIndexCount)
                break;
        }
    }

    device atomic_uint *chunkCount = (device atomic_uint *)&range.length;
    const uint cid = range.location + (gPackCommands ? atomic_fetch_add_explicit(chunkCount, 1, metal::memory_order_relaxed) : tid);

    if(gEncodeToDepthOnly)
    {
        render_command cmd(encodeArgs.cmdBufferDepthOnly, cid);
        encodeChunkCommand_DepthOnly(cmd, cameraParams, encodeArgs, materialBuffer, chunk.materialIndex, chunk.indexBegin, indexCount);
    }

    if(gEncodeToMain)
    {
        render_command cmd(encodeArgs.cmdBuffer, cid);

        // Acturally encode the draw command into the indirect command buffer
        encodeChunkCommand(cmd, cameraParams, encodeArgs, materialBuffer, chunk.materialIndex, chunk.indexBegin, indexCount);

        if (gVisualizeCulling)
        {
            uint cascadeCount = 0;
            for(uint i = 0 ; i < SHADOW_CASCADE_COUNT ; i++)
                cascadeCount += sphereInFrustum(encodeArgs.frameDataBuffer->shadowCameraParams[i], chunk.boundingSphere);
            chunkViz[cid].cascadeCount = cascadeCount;

            chunkViz[cid].index = cid + cullParams.offset;
            chunkViz[cid].cullType = frustumCulled ? XCullResultFrustumCulled : (occlusionCulled ? XCullResultOcclusionCulled : XCullResultNotCulled);
            cmd.set_fragment_buffer(&chunkViz[cid], XBufferIndexFragmentChunkViz);
        }
    }
}

#if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
kernel void encodeChunksWithCullingFiltered(const uint tid                                          [[ thread_position_in_grid ]],
                                            const uint indexInTG                                    [[ thread_index_in_threadgroup ]],
                                            constant XCullParams & cullParams                    [[ buffer(XBufferIndexCullParams) ]],
                                            constant XCameraParams & cullCameraParams1           [[ buffer(XBufferIndexComputeCullCameraParams) ]],
                                            constant XCameraParams & cullCameraParams2           [[ buffer(XBufferIndexComputeCullCameraParams2) ]],
                                            constant XCameraParams & cameraParams                [[ buffer(XBufferIndexCameraParams) ]],
                                            constant XEncodeArguments & encodeArgs               [[ buffer(XBufferIndexComputeEncodeArguments) ]],
                                            const device XShaderMaterial * materialBuffer        [[ buffer(XBufferIndexComputeMaterial) ]],
                                            device MTLIndirectCommandBufferExecutionRange & range   [[ buffer(XBufferIndexComputeExecutionRange) ]],
                                            device XMeshChunk * chunks                           [[ buffer(XBufferIndexComputeChunks) ]],
                                            device XChunkVizData * chunkViz                      [[ buffer(XBufferIndexComputeChunkViz), function_constant(gVisualizeCulling) ]],
                                            constant XFrameConstants & frameData                 [[ buffer(XBufferIndexComputeFrameData) ]],
                                            texture2d<float> depthPyramid1                          [[ texture(0), function_constant(gUseOcclusionCulling) ]],
                                            texture2d<float> depthPyramid2                          [[ texture(1), function_constant(gUseOcclusionCulling) ]])
{
    threadgroup uint visible[CULLING_THREADGROUP_SIZE];

    // Array of index count to add to the render command from the previous chunk
    threadgroup uint indexCountFollowingPrevious[CULLING_THREADGROUP_SIZE];

    bool validChunk = tid < cullParams.numChunks;

    bool wouldHaveBeenVisible = true;

    const uint chunkIdx = min(tid, cullParams.numChunks - 1);

    device XMeshChunk &chunk = chunks[chunkIdx];

    bool frustumCulled = false;
    bool occlusionCulled = false;

    if(validChunk)
    {
        indexCountFollowingPrevious[indexInTG] = 0;
        visible[indexInTG] = 0;

        {
            frustumCulled = !sphereInFrustum(cullCameraParams1, chunk.boundingSphere);

            if (!gVisualizeCulling && frustumCulled)
                wouldHaveBeenVisible = false;

            occlusionCulled = ((gVisualizeCulling && frustumCulled) ||
                               (gUseOcclusionCulling &&
                                chunkOccluded(frameData, cullCameraParams1,
                                              nullptr,
                                              depthPyramid1, chunk)));

            if (!gVisualizeCulling && occlusionCulled)
                wouldHaveBeenVisible = false;
        }

        if(!wouldHaveBeenVisible)
        {
            frustumCulled = !sphereInFrustum(cullCameraParams2, chunk.boundingSphere);

            frustumCulled = (!gVisualizeCulling && frustumCulled);

            occlusionCulled = ((gVisualizeCulling && frustumCulled) ||
                               (gUseOcclusionCulling &&
                                chunkOccluded(frameData, cullCameraParams2,
                                              nullptr,
                                              depthPyramid2, chunk)));

            occlusionCulled = (!gVisualizeCulling && occlusionCulled);
        }

        visible[indexInTG] = 1;
    }

    threadgroup_barrier(mem_flags::mem_threadgroup);

    if(validChunk && indexInTG > 0 && !wouldHaveBeenVisible && !(occlusionCulled || frustumCulled))
    {
        const device XMeshChunk &prev = chunks[tid-1];

        bool isContiguousWithPrevious;
        // Previous is also visible and can write this
        isContiguousWithPrevious = visible[indexInTG-1];

        // Share the same material
        isContiguousWithPrevious &= (chunk.materialIndex == prev.materialIndex);

        // Contiguous sets of indices
        isContiguousWithPrevious &= (chunk.indexBegin == (prev.indexBegin + prev.indexCount));

        indexCountFollowingPrevious[indexInTG] = isContiguousWithPrevious ? chunk.indexCount : 0;
    }

    threadgroup_barrier(mem_flags::mem_threadgroup);

    if(!validChunk ||                              // Less than the number of valid objects
       (!gVisualizeCulling &&                      // Culling visualization required
        (indexCountFollowingPrevious[indexInTG] || // Previous chunk will write this chunk
         wouldHaveBeenVisible ||                   // Visible to other camera
         occlusionCulled ||                        // Occlusion culled
         frustumCulled)))                          // Frustunm culled
    {
        return;
    }

    uint indexCount = chunk.indexCount;
    if(!gVisualizeCulling)
    {
        for(uint localTGID = indexInTG+1, localTID = tid+1;
            (localTGID < CULLING_THREADGROUP_SIZE) &&  (localTID < cullParams.numChunks);
            localTGID++, localTID++)
        {
            uint extraIndexCount = indexCountFollowingPrevious[localTGID];
            indexCount += extraIndexCount;
            if(!extraIndexCount)
                break;
        }
    }

    device atomic_uint *chunkCount = (device atomic_uint *)&range.length;
    const uint cid = range.location + (gPackCommands ? atomic_fetch_add_explicit(chunkCount, 1, metal::memory_order_relaxed) : tid);

    if(gEncodeToDepthOnly)
    {
        render_command cmd(encodeArgs.cmdBufferDepthOnly, cid);
        encodeChunkCommand_DepthOnly(cmd, cameraParams, encodeArgs, materialBuffer, chunk.materialIndex, chunk.indexBegin, indexCount);
    }

    if(gEncodeToMain)
    {
        render_command cmd(encodeArgs.cmdBuffer, cid);

        encodeChunkCommand(cmd, cameraParams, encodeArgs, materialBuffer, chunk.materialIndex, chunk.indexBegin, indexCount);

        if (gVisualizeCulling)
        {
            chunkViz[cid].index = cid + cullParams.offset;
            chunkViz[cid].cullType = frustumCulled ? XCullResultFrustumCulled : (occlusionCulled ? XCullResultOcclusionCulled : XCullResultNotCulled);
            cmd.set_fragment_buffer(&chunkViz[cid], XBufferIndexFragmentChunkViz);
        }
    }
}
#endif

