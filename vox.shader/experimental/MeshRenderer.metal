//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "LightingCommon.h"
#import "ShaderCommon.h"
#import "CullingShared.h"

//------------------------------------------------------------------------------

// Toggled for objects with alpha mask during rendering to discard fragments
//  with an alpha less than ALPHA_CUTOUT.
constant bool gUseAlphaMask            [[function_constant(XFunctionConstIndexAlphaMask)]];

constant uint gLightCullingTileSize    [[function_constant(XFunctionConstIndexLightCullingTileSize)]];

// Toggled for transparent objects to disable effects that do not affect transparencies.
constant bool gTransparent             [[function_constant(XFunctionConstIndexTransparent)]];

// Toggled to enable debug rendering to reduce the cost of the default shading
//  by not caching values for possible debug output.
constant bool gEnableDebugView         [[function_constant(XFunctionConstIndexDebugView)]];

constant bool gUseLightCluster         [[function_constant(XFunctionConstIndexLightCluster)]];

constant uint gLightClusteringTileSize [[function_constant(XFunctionConstIndexLightClusteringTileSize)]];
//------------------------------------------------------------------------------

#pragma mark Vertex input/output structures

// Default vertex type.
struct XVertex
{
    float3 position     [[attribute(XVertexAttributePosition)]];
    xhalf3 normal       [[attribute(XVertexAttributeNormal)]];
    xhalf3 tangent      [[attribute(XVertexAttributeTangent)]];
    float2 texCoord     [[attribute(XVertexAttributeTexcoord)]];
};

// Output from the main rendering vertex shader.
struct XVertexOutput
{
    float4 position [[position]];
    float4 frozenPosition;
    xhalf3 viewDir;
    xhalf3 normal;
    xhalf3 tangent;
    float2 texCoord;
    float3 wsPosition;
};

// Depth only vertex type.
struct XDepthOnlyVertex
{
    float3 position [[attribute(XVertexAttributePosition)]];
};

// Depth only vertex output type.
struct XDepthOnlyVertexOutput
{
    float4 position [[position]];
};

// Depth only vertex type with texcoord for alpha mask.
struct XDepthOnlyAlphaMaskVertex
{
    float3 position [[attribute(XVertexAttributePosition)]];
    float2 texCoord [[attribute(XVertexAttributeTexcoord)]];
};

// Depth only vertex output type with texcoord for alpha mask.
struct XDepthOnlyAlphaMaskVertexOutput
{
    float4 position [[position]];
    float2 texCoord;
};

//------------------------------------------------------------------------------

xhalf4 sampleMaterialTexture(texture2d<xhalf> texture, float2 texc, uint minMip)
{
    constexpr sampler samp(mip_filter::linear, mag_filter::linear, min_filter::linear, address::repeat, max_anisotropy(MAX_ANISOTROPY));

#if SUPPORT_SPARSE_TEXTURES
#   if SUPPORT_PAGE_ACCESS_COUNTERS
        sparse_color<vec<xhalf, 4>> v = texture.sparse_sample(samp, texc);

        if(v.resident())
            return v.value();
        else
#   endif // SUPPORT_PAGE_ACCESS_COUNTERS
            return texture.sample(samp, texc, min_lod_clamp(minMip));
#else // !SUPPORT_SPARSE_TEXTURES
    return texture.sample(samp, texc);
#endif // !SUPPORT_SPARSE_TEXTURES
}

//------------------------------------------------------------------------------

// Calculates the PBR surface data with the data from the pixel and the material
//  applied.
static XPixelSurfaceData getPixelSurfaceData(const XVertexOutput in, constant XShaderMaterial& material, bool isFrontFace)
{
    xhalf4 baseColor    = sampleMaterialTexture(material.albedo, in.texCoord.xy, MATERIAL_BASE_COLOR_MIP);
    xhalf4 materialData = xhalf4(0.0f, 0.0f, 0.0f, 0.0f);
    xhalf3 emissive     = 0.0f;

#if 0 && USE_TEXTURE_STREAMING // Streaming mip visualisation.
    baseColor = baseColor * 0.001f + (xhalf4)HEATMAP_COLORS[HEATMAP_LEVELS - min(material.baseColorMip, HEATMAP_LEVELS - 1)];
#endif

    if(material.hasMetallicRoughness)
        materialData = sampleMaterialTexture(material.metallicRoughness, in.texCoord.xy, MATERIAL_METALLIC_ROUGHNESS_MIP);

    if(material.hasEmissive)
        emissive = sampleMaterialTexture(material.emissive, in.texCoord.xy, MATERIAL_EMISSIVE_MIP).rgb;

    xhalf3 geonormal    = normalize(in.normal);
    xhalf3 geotan       = normalize(in.tangent);
    xhalf3 geobinormal  = normalize(cross(geotan, geonormal));

    xhalf3 texnormal = sampleMaterialTexture(material.normal, in.texCoord.xy, MATERIAL_NORMAL_MIP).xyz;
    texnormal.xy = texnormal.xy * 2.0 - 1.0f;
    texnormal.z = sqrt(saturate(1.0f - dot(texnormal.xy, texnormal.xy)));

    xhalf3 normal = texnormal.b * geonormal - texnormal.g * geotan + texnormal.r * geobinormal;

    if(!isFrontFace)
        normal *= -1.0f;

    XPixelSurfaceData output;
    output.normal       = normal;
    output.albedo       = mix(baseColor.rgb, 0.0f, materialData.b);
    output.F0           = mix((xhalf)0.04, baseColor.rgb, materialData.b);
    output.roughness    = max((xhalf)0.08, materialData.g);
    output.alpha        = baseColor.a * material.alpha;
    output.emissive     = emissive;

    if(gTransparent)
        output.albedo *= output.alpha;

    return output;
}

void applyChunkVizModifiers(thread XPixelSurfaceData& surfaceData, float4 frozenPosition, xhalf3 normal,
                            constant XChunkVizData & chunkViz, constant XFrameConstants & frameData, constant XGlobalTextures & globalTextures)
{
    if (gEnableDebugView)
    {
        if(frameData.visualizeCullingMode == XVisualizationTypeChunkIndex)
            surfaceData.albedo = wang_color(chunkViz.index);

        const xhalf3 frustumCulledDebugColor = xhalf3(0.4,0,0.4);
        const xhalf3 occlusionCulledDebugColor = xhalf3(0,0.4,0.4);

        bool showFrustumCulled      = (frameData.visualizeCullingMode >= XVisualizationTypeFrustumCull) && (chunkViz.cullType == XCullResultFrustumCulled);
        bool showOcclusionCulled    = (frameData.visualizeCullingMode >= XVisualizationTypeFrustumCullOcclusionCull) && (chunkViz.cullType == XCullResultOcclusionCulled);

        if (showFrustumCulled)
        {
            surfaceData.albedo = frustumCulledDebugColor;
            surfaceData.F0 = 0.04;
            surfaceData.roughness = 1.0f;
        }
        else if (showOcclusionCulled)
        {
            surfaceData.albedo = occlusionCulledDebugColor;
            surfaceData.F0 = 0.04;
            surfaceData.roughness = 1.0f;
        }
        else if(frameData.visualizeCullingMode == XVisualizationTypeCascadeCount)
        {
            switch(chunkViz.cascadeCount)
            {
                case 0:
                    surfaceData.albedo = xhalf3(1, 1, 1);
                    break;
                case 1:
                    surfaceData.albedo = xhalf3(0, 1, 0);
                    break;
                case 2:
                    surfaceData.albedo = xhalf3(1, 1, 0);
                    break;
                case 3:
                    surfaceData.albedo = xhalf3(1, 0, 0);
                    break;
            }
            surfaceData.F0 = 0.04;
            surfaceData.roughness = 1.0f;
        }
        else
        {
            // Modulate surface brightness based on out-of-frustum and occlusion
            bool clipped = (frameData.visualizeCullingMode >= 1) && (frozenPosition.w < 0 || any(abs(frozenPosition.xyz) > frozenPosition.w));
            bool culled = false;

            if (frameData.visualizeCullingMode >= XVisualizationTypeFrustumCullOcclusion)
            {
                // Test for depth pyramid occlusion
                float3 dpc = frozenPosition.xyz / frozenPosition.w;
                dpc.xy = dpc.xy * float2(0.5, -0.5) + 0.5;

                constexpr sampler samp(filter::linear, mip_filter::none, compare_func::greater);
                float occlusion = globalTextures.viewDepthPyramid.sample_compare(samp, dpc.xy, dpc.z);

                culled = occlusion > 0.5f;
            }

            if(clipped || culled)
            {
                surfaceData.albedo = 0.05f;
                surfaceData.normal = normal;
            }
        }

#if 0 // Culling viz transparency.
        bool showCulled = showFrustumCulled || showOcclusionCulled;
        if (showCulled && (as_type<uint>(fp.x + fp.y) % 4))
            discard_fragment();
#endif
    }
}

//------------------------------------------------------------------------------

// Depth only vertex shader.
vertex XDepthOnlyVertexOutput vertexShaderDepthOnly(XDepthOnlyVertex in                   [[ stage_in ]],
                                                       constant XCameraParams & cameraParams [[ buffer(XBufferIndexCameraParams) ]])
{
    XDepthOnlyVertexOutput out;
    out.position = cameraParams.viewProjectionMatrix * float4(in.position, 1.0);

    return out;
}

// Depth only vertex shader with texcoord for alpha mask texture.
vertex XDepthOnlyAlphaMaskVertexOutput vertexShaderDepthOnlyAlphaMask(XDepthOnlyAlphaMaskVertex in          [[ stage_in ]],
                                                                         constant XCameraParams & cameraParams [[ buffer(XBufferIndexCameraParams) ]])
{
    XDepthOnlyAlphaMaskVertexOutput out;
    out.position = cameraParams.viewProjectionMatrix * float4(in.position, 1.0);
    out.texCoord = in.texCoord;

    return out;
}

#if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
//------------------------------------------------------------------------------

// Depth only vertex shader with amplification.
// Assumed to be rendering cascades 1 & 2 if used.
vertex XDepthOnlyVertexOutput vertexShaderDepthOnlyAmplified(XDepthOnlyVertex in                  [[ stage_in ]],
                                                                ushort amp_id                           [[ amplification_id ]],
                                                                constant XFrameConstants & frameData [[ buffer(XBufferIndexFrameData) ]])
{
    XDepthOnlyVertexOutput out;
    out.position = frameData.shadowCameraParams[1 + amp_id].viewProjectionMatrix * float4(in.position, 1.0);

    return out;
}

// Depth only vertex shader with texcoord for alpha mask texture with amplification.
// Assumed to be rendering cascades 1 & 2 if used.
vertex XDepthOnlyAlphaMaskVertexOutput vertexShaderDepthOnlyAlphaMaskAmplified(XDepthOnlyAlphaMaskVertex in         [[ stage_in ]],
                                                                                  ushort amp_id                           [[ amplification_id ]],
                                                                                  constant XFrameConstants & frameData [[ buffer(XBufferIndexFrameData) ]])
{
    XDepthOnlyAlphaMaskVertexOutput out;
    out.position = frameData.shadowCameraParams[1 + amp_id].viewProjectionMatrix * float4(in.position, 1.0);
    out.texCoord = in.texCoord;

    return out;
}
#endif // SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION

//------------------------------------------------------------------------------

// Main rendering vertex shader.
vertex XVertexOutput vertexShader(XVertex in                          [[ stage_in ]],
                                   constant XFrameConstants & frameData  [[ buffer(XBufferIndexFrameData) ]],
                                   constant XCameraParams & cameraParams [[ buffer(XBufferIndexCameraParams) ]])
{
    XVertexOutput out;

    float4 position = float4(in.position, 1.0);
    out.position        = cameraParams.viewProjectionMatrix * position;
    out.frozenPosition  = frameData.cullParams.viewProjectionMatrix * position;
    out.viewDir         = (xhalf3)normalize(cameraParams.invViewMatrix[3].xyz - in.position);
    out.normal          = normalize(in.normal);
    out.tangent         = normalize(in.tangent);
    out.texCoord        = in.texCoord;
    out.wsPosition  = in.position;

    return out;
}

//------------------------------------------------------------------------------

// Default fragment shader for populating the GBuffer.
//  Includes overrides for visualizing chunk culling if the gEnableDebugView
//  function constant is set to true.
fragment XGBufferFragOut fragmentGBufferShader(XVertexOutput in                          [[ stage_in ]],
                                                  constant XFrameConstants & frameData      [[ buffer(XBufferIndexFrameData) ]],
                                                  constant XShaderMaterial & material       [[ buffer(XBufferIndexFragmentMaterial) ]],
                                                  constant XGlobalTextures & globalTextures [[ buffer(XBufferIndexFragmentGlobalTextures) ]],
                                                  constant XChunkVizData & chunkViz         [[ buffer(XBufferIndexFragmentChunkViz), function_constant(gEnableDebugView) ]],
                                                  bool is_front_face                           [[ front_facing]]
                                                  )
{
    XPixelSurfaceData surfaceData = getPixelSurfaceData(in, material, is_front_face);

    applyChunkVizModifiers(surfaceData, in.frozenPosition, in.normal, chunkViz, frameData, globalTextures);

#if !USE_EQUAL_DEPTH_TEST // not required when using depth pre pass
    if(gUseAlphaMask && surfaceData.alpha < ALPHA_CUTOUT)
        discard_fragment();
#endif

    XGBufferFragOut out;
    out.albedo      = xhalf4(surfaceData.albedo, surfaceData.alpha);
    out.normals     = xhalf4(surfaceData.normal, 0.0f);
    out.emissive    = xhalf4(surfaceData.emissive, 0.0f);
    out.F0Roughness = xhalf4(surfaceData.F0, surfaceData.roughness);
    return out;
}

//------------------------------------------------------------------------------

// Fragment shader for forward rendering.
// Uses function constants to enable alpha masking and transparency, as well as
//  debug output from lightingShader().
fragment xhalf4 fragmentForwardShader(XVertexOutput in                          [[ stage_in ]],
                                      constant XFrameConstants & frameData      [[ buffer(XBufferIndexFrameData) ]],
                                      constant XCameraParams & cameraParams     [[ buffer(XBufferIndexCameraParams) ]],
                                      constant XShaderMaterial & material       [[ buffer(XBufferIndexFragmentMaterial) ]],
                                      constant XGlobalTextures & globalTextures [[ buffer(XBufferIndexFragmentGlobalTextures) ]],
                                      constant XShaderLightParams & lightParams [[ buffer(XBufferIndexFragmentLightParams) ]],
                                      constant XChunkVizData & chunkViz         [[ buffer(XBufferIndexFragmentChunkViz), function_constant(gEnableDebugView) ]],
                                      bool is_front_face                           [[ front_facing ]]
                                      )
{
    XPixelSurfaceData surfaceData    = getPixelSurfaceData(in, material, is_front_face);
    surfaceData.F0                      = mix(surfaceData.F0, (xhalf)0.02, (xhalf)frameData.wetness);
    surfaceData.roughness               = mix(surfaceData.roughness, (xhalf)0.1, (xhalf)frameData.wetness);

    applyChunkVizModifiers(surfaceData, in.frozenPosition, in.normal, chunkViz, frameData, globalTextures);

#if !USE_EQUAL_DEPTH_TEST // not required when using depth pre pass
    if(gUseAlphaMask && surfaceData.alpha < ALPHA_CUTOUT)
        discard_fragment();
#endif

    // Alpha clip is actually transparent but it doesn't blend -> scattering is incorrect.
    if (gUseAlphaMask)
        surfaceData.alpha = 1.0;

    float3 worldPosition = in.wsPosition;

#if USE_SCALABLE_AMBIENT_OBSCURANCE
    float aoSample = (gTransparent || (gEnableDebugView && frameData.visualizeCullingMode > XVisualizationTypeCascadeCount)) ? 1.0f : globalTextures.saoTexture.read((uint2)in.position.xy).x;
#else
    float aoSample = 1.0f;
#endif

    float depth = in.position.z;

    uint tileIdx;
    if (gUseLightCluster)
    {
        uint tileX = in.position.x / gLightClusteringTileSize;
        uint tileY = in.position.y / gLightClusteringTileSize;

#if LOCAL_LIGHT_SCATTERING
        uint cluster = zToScatterDepth(linearizeDepth(cameraParams, depth)) * LIGHT_CLUSTER_DEPTH;
        cluster = min(cluster, LIGHT_CLUSTER_DEPTH-1u);
#else
        float depthStep = LIGHT_CLUSTER_RANGE / LIGHT_CLUSTER_DEPTH;
        uint cluster = linearizeDepth(cameraParams, depth) / depthStep;
        cluster = min(cluster, LIGHT_CLUSTER_DEPTH-1u);
#endif

        tileIdx = (tileX + frameData.lightIndicesParams.y * tileY + frameData.lightIndicesParams.z * cluster) * MAX_LIGHTS_PER_CLUSTER;
    }
    else
    {
        uint tileX = in.position.x / gLightCullingTileSize;
        uint tileY = in.position.y / gLightCullingTileSize;

        tileIdx = (tileX + frameData.lightIndicesParams.x * tileY) * MAX_LIGHTS_PER_TILE;
    }

    constant uint8_t *pointLightIndices;
    constant uint8_t *spotLightIndices;
    if (gTransparent)
    {
        pointLightIndices = lightParams.pointLightIndicesTransparent + tileIdx;
        spotLightIndices = lightParams.spotLightIndicesTransparent + tileIdx;
    }
    else
    {
        pointLightIndices = lightParams.pointLightIndices + tileIdx;
        spotLightIndices = lightParams.spotLightIndices + tileIdx;
    }

    xhalf4 result;
    result.rgb = lightingShader(surfaceData,
                                aoSample,
                                depth,
                                float4(worldPosition, 1),
                                frameData,
                                cameraParams,
                                globalTextures.shadowMap,
                                globalTextures.dfgLutTex,
                                globalTextures.envMap,
                                lightParams.pointLightBuffer,
                                lightParams.spotLightBuffer,
                                pointLightIndices,
                                spotLightIndices,
#if USE_SPOT_LIGHT_SHADOWS
                                globalTextures.spotShadowMaps,
#endif
                                gEnableDebugView);
    result.a = surfaceData.alpha;

#if USE_SCATTERING_VOLUME
    if(!gEnableDebugView)
        result = applyScattering(result, uint2(in.position.xy), in.position.xy * frameData.invPhysicalSize, depth,
                                 globalTextures.scattering, globalTextures.blueNoise, frameData, cameraParams);
#endif

    return result;
}

//------------------------------------------------------------------------------

// Depth only fragment shader with alpha mask.
fragment void fragmentShaderDepthOnlyAlphaMask(const XDepthOnlyAlphaMaskVertexOutput in       [[ stage_in ]],
                                               constant XShaderMaterial&             material [[ buffer(XBufferIndexFragmentMaterial) ]])
{
    if (sampleMaterialTexture(material.albedo, in.texCoord, MATERIAL_BASE_COLOR_MIP).a < ALPHA_CUTOUT)
        discard_fragment();
}

#if SUPPORT_DEPTH_PREPASS_TILE_SHADERS

// Fragment shader to store depth to imageblock memory.
fragment TileFragOut fragmentShaderDepthOnlyTile(const XDepthOnlyVertexOutput in [[stage_in]])
{
    TileFragOut out;

    out.depth = in.position.z;

    return out;
}

// Fragment shader to store depth to imageblock memory, using a texture alpha
//  mask to discard cutout pixels.
fragment TileFragOut fragmentShaderDepthOnlyTileAlphaMask(const XDepthOnlyAlphaMaskVertexOutput in [[stage_in]],
                                                          constant XShaderMaterial& material       [[ buffer(XBufferIndexFragmentMaterial) ]])
{
    if (sampleMaterialTexture(material.albedo, in.texCoord, MATERIAL_BASE_COLOR_MIP).a < ALPHA_CUTOUT)
        discard_fragment();

    TileFragOut out;
    out.depth = in.position.z;

    return out;
}

#endif // SUPPORT_DEPTH_PREPASS_TILE_SHADERS

//------------------------------------------------------------------------------
