//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "../function_common.h"
#include "../function_constant.h"
#include "../shader_common.h"
#include "lighting_common.h"

/// Output from the main rendering vertex shader.
struct VertexOutput {
    float4 position [[position]];
    float4 frozenPosition;
    xhalf3 viewDir;
    xhalf3 normal;
    xhalf3 tangent;
    float2 texCoord;
    float3 wsPosition;
};

/// Depth only vertex output type.
struct DepthOnlyVertexOutput {
    float4 position [[position]];
};

/// Depth only vertex output type with texcoord for alpha mask.
struct DepthOnlyAlphaMaskVertexOutput {
    float4 position [[position]];
    float2 texCoord;
};

//------------------------------------------------------------------------------

xhalf4 sampleMaterialTexture(texture2d<xhalf> texture, float2 texc, uint minMip) {
    constexpr sampler samp(mip_filter::linear, mag_filter::linear, min_filter::linear,
                           address::repeat, max_anisotropy(MAX_ANISOTROPY));

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
static PixelSurfaceData getPixelSurfaceData(const VertexOutput in,
                                            constant ShaderMaterial& material,
                                            bool isFrontFace) {
    xhalf4 baseColor    = sampleMaterialTexture(material.albedo, in.texCoord.xy, MATERIAL_BASE_COLOR_MIP);
    xhalf4 materialData = xhalf4(0.0f, 0.0f, 0.0f, 0.0f);
    xhalf3 emissive     = 0.0f;

#if 0 && USE_TEXTURE_STREAMING // Streaming mip visualisation.
    baseColor = baseColor * 0.001f + (xhalf4)HEATMAP_COLORS[HEATMAP_LEVELS - min(material.baseColorMip, HEATMAP_LEVELS - 1)];
#endif

    if(material.hasMetallicRoughness)
        materialData = sampleMaterialTexture(material.metallicRoughness,
                                             in.texCoord.xy, MATERIAL_METALLIC_ROUGHNESS_MIP);

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

    PixelSurfaceData output;
    output.normal       = normal;
    output.albedo       = mix(baseColor.rgb, 0.0f, materialData.b);
    output.F0           = mix((xhalf)0.04, baseColor.rgb, materialData.b);
    output.roughness    = max((xhalf)0.08, materialData.g);
    output.alpha        = baseColor.a * material.alpha;
    output.emissive     = emissive;

    if(isTransparent)
        output.albedo *= output.alpha;

    return output;
}

//------------------------------------------------------------------------------

// Depth only vertex shader.
vertex DepthOnlyVertexOutput vertexShaderDepthOnly(VertexIn in [[ stage_in ]],
                                                   constant CameraData &cameraParams [[ buffer(2) ]]) {
    DepthOnlyVertexOutput out;
    out.position = cameraParams.u_VPMat * float4(in.POSITION, 1.0);

    return out;
}

// Depth only vertex shader with texcoord for alpha mask texture.
vertex DepthOnlyAlphaMaskVertexOutput vertexShaderDepthOnlyAlphaMask(VertexIn in [[ stage_in ]],
                                                                     constant CameraData &cameraParams [[buffer(0) ]]) {
    DepthOnlyAlphaMaskVertexOutput out;
    out.position = cameraParams.u_VPMat * float4(in.POSITION, 1.0);
    out.texCoord = in.TEXCOORD_0;

    return out;
}

#if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
//------------------------------------------------------------------------------

// Depth only vertex shader with amplification.
// Assumed to be rendering cascades 1 & 2 if used.
vertex DepthOnlyVertexOutput vertexShaderDepthOnlyAmplified(VertexIn in [[ stage_in ]],
                                                            ushort amp_id [[ amplification_id ]],
                                                            constant FrameConstants & frameData [[ buffer(0) ]]) {
    DepthOnlyVertexOutput out;
    out.position = frameData.shadowCameraParams[1 + amp_id].u_VPMat * float4(in.POSITION, 1.0);

    return out;
}

// Depth only vertex shader with texcoord for alpha mask texture with amplification.
// Assumed to be rendering cascades 1 & 2 if used.
vertex DepthOnlyAlphaMaskVertexOutput vertexShaderDepthOnlyAlphaMaskAmplified(VertexIn in [[ stage_in ]],
                                                                              ushort amp_id [[ amplification_id ]],
                                                                              constant FrameConstants & frameData [[ buffer(0) ]]) {
    DepthOnlyAlphaMaskVertexOutput out;
    out.position = frameData.shadowCameraParams[1 + amp_id].u_VPMat * float4(in.POSITION, 1.0);
    out.texCoord = in.TEXCOORD_0;

    return out;
}
#endif // SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION

//------------------------------------------------------------------------------

// Main rendering vertex shader.
vertex VertexOutput vertexShader(VertexIn in [[ stage_in ]],
                                 constant FrameConstants & frameData  [[ buffer(0) ]],
                                 constant CameraData & cameraParams [[ buffer(1) ]]) {
    VertexOutput out;

    float4 position = float4(in.POSITION, 1.0);
    out.position        = cameraParams.u_VPMat * position;
    out.frozenPosition  = frameData.cullParams.u_VPMat * position;
    out.viewDir         = (xhalf3)normalize(cameraParams.u_viewInvMat[3].xyz - in.POSITION);
    out.normal          = normalize(xhalf3(in.NORMAL.x, in.NORMAL.y, in.NORMAL.z));
    out.tangent         = normalize(xhalf3(in.TANGENT.x, in.TANGENT.y, in.TANGENT.z));
    out.texCoord        = in.TEXCOORD_0;
    out.wsPosition  = in.POSITION;

    return out;
}

//------------------------------------------------------------------------------

// Default fragment shader for populating the GBuffer.
//  Includes overrides for visualizing chunk culling if the gEnableDebugView
//  function constant is set to true.
fragment GBufferFragOut fragmentGBufferShader(VertexOutput in [[ stage_in ]],
                                              constant FrameConstants & frameData [[ buffer(0) ]],
                                              constant ShaderMaterial & material [[ buffer(1) ]],
                                              constant GlobalTextures & globalTextures [[ buffer(2) ]],
                                              bool is_front_face [[ front_facing]]) {
    PixelSurfaceData surfaceData = getPixelSurfaceData(in, material, is_front_face);

#if !USE_EQUAL_DEPTH_TEST // not required when using depth pre pass
    if(needAlphaCutoff && surfaceData.alpha < ALPHA_CUTOUT)
        discard_fragment();
#endif

    GBufferFragOut out;
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
fragment xhalf4 fragmentForwardShader(VertexOutput in [[ stage_in ]],
                                      constant FrameConstants & frameData [[ buffer(0) ]],
                                      constant CameraData & cameraParams [[ buffer(1) ]],
                                      constant ShaderMaterial & material [[ buffer(2) ]],
                                      constant GlobalTextures & globalTextures [[ buffer(3) ]],
                                      constant ShaderLightParams & lightParams [[ buffer(4) ]],
                                      bool is_front_face [[ front_facing ]]) {
    PixelSurfaceData surfaceData = getPixelSurfaceData(in, material, is_front_face);
    surfaceData.F0 = mix(surfaceData.F0, (xhalf)0.02, (xhalf)frameData.wetness);
    surfaceData.roughness = mix(surfaceData.roughness, (xhalf)0.1, (xhalf)frameData.wetness);

#if !USE_EQUAL_DEPTH_TEST // not required when using depth pre pass
    if(gUseAlphaMask && surfaceData.alpha < ALPHA_CUTOUT)
        discard_fragment();
#endif

    // Alpha clip is actually transparent but it doesn't blend -> scattering is incorrect.
    if (needAlphaCutoff)
        surfaceData.alpha = 1.0;

    float3 worldPosition = in.wsPosition;

#if USE_SCALABLE_AMBIENT_OBSCURANCE
    float aoSample = (isTransparent || (needDebugView && frameData.visualizeCullingMode > VisualizationTypeCascadeCount))
    ? 1.0f : globalTextures.saoTexture.read((uint2)in.position.xy).x;
#else
    float aoSample = 1.0f;
#endif

    float depth = in.position.z;

    uint tileIdx;
    if (needLightCluster) {
        uint tileX = in.position.x / lightClusteringTileSize;
        uint tileY = in.position.y / lightClusteringTileSize;

#if LOCAL_LIGHT_SCATTERING
        uint cluster = zToScatterDepth(linearizeDepth(cameraParams, depth)) * LIGHT_CLUSTER_DEPTH;
        cluster = min(cluster, LIGHT_CLUSTER_DEPTH-1u);
#else
        float depthStep = LIGHT_CLUSTER_RANGE / LIGHT_CLUSTER_DEPTH;
        uint cluster = linearizeDepth(cameraParams, depth) / depthStep;
        cluster = min(cluster, LIGHT_CLUSTER_DEPTH-1u);
#endif

        tileIdx = (tileX + frameData.lightIndicesParams.y * tileY + frameData.lightIndicesParams.z * cluster) * MAX_LIGHTS_PER_CLUSTER;
    } else {
        uint tileX = in.position.x / lightCullingTileSize;
        uint tileY = in.position.y / lightCullingTileSize;

        tileIdx = (tileX + frameData.lightIndicesParams.x * tileY) * MAX_LIGHTS_PER_TILE;
    }

    constant uint8_t *pointLightIndices;
    constant uint8_t *spotLightIndices;
    if (isTransparent) {
        pointLightIndices = lightParams.pointLightIndicesTransparent + tileIdx;
        spotLightIndices = lightParams.spotLightIndicesTransparent + tileIdx;
    }
    else {
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
                                needDebugView);
    result.a = surfaceData.alpha;

#if USE_SCATTERING_VOLUME
    if(!needDebugView)
        result = applyScattering(result, uint2(in.position.xy), in.position.xy * frameData.invPhysicalSize, depth,
                                 globalTextures.scattering, globalTextures.blueNoise, frameData, cameraParams);
#endif

    return result;
}

//------------------------------------------------------------------------------

// Depth only fragment shader with alpha mask.
fragment void fragmentShaderDepthOnlyAlphaMask(const DepthOnlyAlphaMaskVertexOutput in [[ stage_in ]],
                                               constant ShaderMaterial& material [[ buffer(0) ]]) {
    if (sampleMaterialTexture(material.albedo, in.texCoord, MATERIAL_BASE_COLOR_MIP).a < ALPHA_CUTOUT)
        discard_fragment();
}

#if SUPPORT_DEPTH_PREPASS_TILE_SHADERS

// Fragment shader to store depth to imageblock memory.
fragment TileFragOut fragmentShaderDepthOnlyTile(const DepthOnlyVertexOutput in [[stage_in]]) {
    TileFragOut out;
    out.depth = in.position.z;
    return out;
}

// Fragment shader to store depth to imageblock memory, using a texture alpha
//  mask to discard cutout pixels.
fragment TileFragOut fragmentShaderDepthOnlyTileAlphaMask(const DepthOnlyAlphaMaskVertexOutput in [[stage_in]],
                                                          constant ShaderMaterial& material [[ buffer(0) ]]) {
    if (sampleMaterialTexture(material.albedo, in.texCoord, MATERIAL_BASE_COLOR_MIP).a < ALPHA_CUTOUT)
        discard_fragment();

    TileFragOut out;
    out.depth = in.position.z;

    return out;
}

#endif // SUPPORT_DEPTH_PREPASS_TILE_SHADERS

//------------------------------------------------------------------------------
