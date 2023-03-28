//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <metal_stdlib>
using namespace metal;

#import "../deferred/MainRenderer_shared.h"             // CONST_GAME_TIME
#import "TerrainRendererUtilities.metal"

// Reduce the amount of computations done by the vertex shader and the number of varyings it exports.
// - it is set to true for the shadow pass
constant bool g_isDepthOnlyPass [[function_constant(0)]];
constant bool g_isNotDepthOnlyPass = !g_isDepthOnlyPass;

// No quad support so just return the input.
static inline bool quad_and(bool b)
{
    return b;
}

struct TerrainVertexOut {
    float4 position [[position]];
    float3 worldPosition [[function_constant(g_isNotDepthOnlyPass)]];
    float3 viewDir [[function_constant(g_isNotDepthOnlyPass)]];
    float  depth [[function_constant(g_isNotDepthOnlyPass)]];
    float2 uv [[function_constant(g_isNotDepthOnlyPass)]];
    float3 uvw [[function_constant(g_isNotDepthOnlyPass)]];
};

// Generates a bounce-step between 0...1
float bounceStep(float i)
{
    i = saturate(i*4.0 - 2.0);
    return i*i*(3.0-2.0*i);
}

[[patch(quad, 4)]]
vertex TerrainVertexOut terrain_vertex(uint pid [[patch_id]],
                                       float2 uv [[position_in_patch]],
                                       constant AAPLUniforms& uniforms [[buffer(1)]],
                                       texture2d<float> height [[texture(0)]],
                                       constant float4x4& depthOnlyMatrix[[buffer(6), function_constant(g_isDepthOnlyPass)]])
{
    TerrainVertexOut out;

    uint patchY = pid / TERRAIN_PATCHES;
    uint patchX = pid % TERRAIN_PATCHES;

    float2 patchUV = float2(patchX, patchY) / (TERRAIN_PATCHES);

    float3 position = float3(patchUV.x + uv.x / TERRAIN_PATCHES, 0, patchUV.y + uv.y / TERRAIN_PATCHES);

    // Slowly cycle through different height offsets
    float t = GAME_TIME * 0.4;
    float2 prev_offset = float2(0,0);
    float2 next_offset = float2(0,0);
    float lerp = bounceStep(fract(t));

    constexpr sampler sam(min_filter::linear, mag_filter::linear, mip_filter::none, address::mirrored_repeat);

    position.y = (height.sample(sam, position.xz + next_offset).r) * lerp;
    position.y += (height.sample(sam, position.xz + prev_offset).r) * (1.0 - lerp);

    float3 worldPosition = float3((position.x - 0.5f) * TERRAIN_SCALE, position.y * TERRAIN_HEIGHT, (position.z - 0.5f) * TERRAIN_SCALE);

    if (g_isDepthOnlyPass)
    {
        out.position = depthOnlyMatrix * float4(worldPosition, 1.f);
    }
    else
    {
        out.position = uniforms.cameraUniforms.viewProjectionMatrix * float4(worldPosition, 1.0f);
    }

    // The rest of the parameters aren't necessary for non-shadow passes
    if (g_isNotDepthOnlyPass)
    {
        out.worldPosition = worldPosition;

        out.viewDir = worldPosition - uniforms.cameraUniforms.invViewMatrix[3].xyz;
        out.depth = length(out.viewDir);
        out.viewDir *= (1.f / out.depth);

        out.uv = position.xz;
        out.uvw = worldPosition;
    }

    return out;
}

float4 triplanar (sampler sam, float3 norm, float3 uvw, texture2d_array<float> tex, uint sliceIndex) {
    float3 blending = normalize(max(abs(norm), 0.00001f));
    float b = blending.x + blending.y + blending.z;
    blending /= b;

    float4 x = tex.sample(sam, uvw.yz, sliceIndex);
    float4 y = tex.sample(sam, uvw.xz, sliceIndex);
    float4 z = tex.sample(sam, uvw.xy, sliceIndex);

    return x * blending.x + y * blending.y + z * blending.z;
}

inline float sigmoid(float x, float strength, float threshold) {
    return saturate(1.0f / (1 + exp(-strength * (x - threshold))));
}

inline float materialMask(float slope, float elevation, constant TerrainHabitat& params)
{
    return sigmoid(slope, params.slopeStrength, params.slopeThreshold) * sigmoid(elevation, params.elevationStrength, params.elevationThreshold);
}

static float rand_bilinear (float2 worldCoord, float scale = 400.f)
{
    float2 scaledCoord = (worldCoord+15000)/scale - 0.5;

    const float uint_norm = 1.0 / ((float)uint(0xffffffff));

    uint randSeed = (uint) (floor(scaledCoord.x) + floor(scaledCoord.y)*49.0);
    float randY_0 = float(wang_hash(randSeed  )) * uint_norm;
    float randY_1 = float(wang_hash(randSeed+1)) * uint_norm;
    float a = mix(randY_0, randY_1, fract(scaledCoord.x));

    randSeed = (uint) (floor(scaledCoord.x) + floor(scaledCoord.y+1)*49.0);
    randY_0 = float(wang_hash(randSeed  )) * uint_norm;
    randY_1 = float(wang_hash(randSeed+1)) * uint_norm;
    float b = mix(randY_0, randY_1, fract(scaledCoord.x));

    return mix(a, b, fract(scaledCoord.y));
}

inline BrdfProperties sample_brdf(texture2d_array <float, access::sample>  diffSpecTextureArray,
                                  texture2d_array <float, access::sample>  normalTextureArray,
                                  int curSubLayerIdx,
                                  float textureScale,
                                  float specularPower,
                                  bool flipNormal,
                                  float3 worldPos,
                                  float3 normal,
                                  float3 tangent,
                                  float3 bitangent)
{
    constexpr sampler diffSampler(min_filter::linear, mag_filter::linear, mip_filter::linear, address::repeat);
    constexpr sampler normSampler(min_filter::linear, mag_filter::linear, mip_filter::linear, address::repeat);

    BrdfProperties ret;

    // Sample textures with frac(tex_coordinates) instead of just tex_coordinates.
    // This allows the same visual results even if samplers use different addressing modes (clamp, mirror...).
    // Some Indirect Argument Buffer tests will require sending a large array of samplers to the GPU, but if some are similar, the driver will
    // merge them. You can make them unique by changing their parameters, addressing mode for example, to avoid the merging if needed.
    float4 diffSpec = triplanar(diffSampler, normal, fract(worldPos * textureScale), diffSpecTextureArray, curSubLayerIdx);
    ret.albedo = diffSpec.xyz;

    float3 nmap = triplanar(normSampler, normal, fract(worldPos * textureScale), normalTextureArray, curSubLayerIdx).xyz;

    if (flipNormal)
        nmap.y = 1.0f - nmap.y;

    nmap = normalize(nmap * 2 - 1);
    ret.normal = normalize(nmap.x * tangent + nmap.y * bitangent + nmap.z * normal);

    ret.specIntensity = diffSpec.w;
    ret.specPower = specularPower;

    return ret;
}

fragment GBufferFragOut terrain_fragment(const TerrainVertexOut in [[stage_in]],
                                         constant TerrainParams & mat [[buffer(1)]],
                                         constant AAPLUniforms& globalUniforms [[buffer(2)]],
                                         texture2d<float> heightMap [[texture(0)]],
                                         texture2d<float> normalMap [[texture(1)]],
                                         texture2d<float> propertiesMap [[texture(2)]])
{
    constexpr sampler sam(min_filter::linear, mag_filter::linear, mip_filter::nearest);

    float masks [TerrainHabitatTypeCOUNT];
    float3 normal;

    float noise [4];
    float noise_smooth [4];
    {
        float scale0 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz, 400.f));
        float scale1 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz, 100.f)) * 0.75 + 0.25;
        float scale2 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz, 25.f)) * 0.5 + 0.5;
        float randX = scale0*scale1*scale2;
        noise[0] = smoothstep(0.8, 1.0, 1.0-randX);
        noise_smooth[2]=randX;

        scale0 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz+4000, 300.f));
        scale1 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz+4000, 750.f)) * 0.8 + 0.2;
        scale2 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz+4000, 10.f)) * 0.2 + 0.8;
        randX = scale0*scale1*scale2;
        noise[1] = smoothstep(0.7, 0.95, 1.0-randX);
        noise_smooth[3]=randX;

        scale0 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz+8000, 200.f));
        scale1 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz+8000, 66.f)) * 0.75 + 0.25;
        scale2 = smoothstep(0, 1, rand_bilinear(in.worldPosition.xz+8000, 12.5f)) * 0.5 + 0.5;
        randX = scale0*scale1*scale2;
        noise[2] = smoothstep(0.6, 0.9, 1.0-randX);
        noise_smooth[0]=randX;

        noise[3] = 0.f;

        float remainder = 1.f;

        // For noise [0, 1, 2]
        for (int i = 0; i < 3; i++)
        {
            noise [i] = trim(0.005, noise[i]);
            remainder -= noise [i];

            // For noise [1, 2] [2] []
            for (int j = i+1; j < 3; j++)
            {
                noise [j] *= remainder;
            }
        }
        noise [3] = remainder;
        noise_smooth[1]=randX;
    }

    EvaluateTerrainAtLocation(in.uv, in.worldPosition.xyz, heightMap,
                              normalMap, propertiesMap, mat,
                              masks,
                              normal);

    float3 bitangent = float3(0.0034, 0.0072, 1);
    float3 tangent = normalize(cross(normal, bitangent));
    bitangent = cross(tangent, normal);

    BrdfProperties finalBrdf = {};

    for (int curLayerIdx = 0; curLayerIdx < TerrainHabitatTypeCOUNT; curLayerIdx++)
    {
        const float curLayerWeight = masks [curLayerIdx];
        if (quad_and(curLayerWeight == 0.f)) { continue; }

        BrdfProperties curLayerBrdf {};
        for (int curSubLayerIdx = 0; curSubLayerIdx < VARIATION_COUNT_PER_HABITAT; curSubLayerIdx++)
        {
            const float curSubLayerWeight = noise [curSubLayerIdx];
            if (quad_and(curSubLayerWeight == 0.f)) { continue; }

            BrdfProperties curSubLayerBrdf = sample_brdf(
                                                         mat.habitats [curLayerIdx].diffSpecTextureArray,
                                                         mat.habitats [curLayerIdx].normalTextureArray,
                                                         curSubLayerIdx,
                                                         mat.habitats [curLayerIdx].textureScale,
                                                         mat.habitats [curLayerIdx].specularPower,
                                                         mat.habitats [curLayerIdx].flipNormal,
                                                         in.worldPosition,
                                                         normal,
                                                         tangent,
                                                         bitangent);

            curLayerBrdf.albedo        += curSubLayerBrdf.albedo    * curSubLayerWeight * (noise_smooth[curSubLayerIdx]*0.2+0.8);
            curLayerBrdf.normal        += curSubLayerBrdf.normal    * curSubLayerWeight;
            curLayerBrdf.specIntensity += curSubLayerBrdf.specIntensity * curSubLayerWeight;
            curLayerBrdf.specPower     += curSubLayerBrdf.specPower * curSubLayerWeight;
        }

        finalBrdf.albedo        += curLayerBrdf.albedo    * curLayerWeight;
        finalBrdf.normal        += curLayerBrdf.normal    * curLayerWeight;
        finalBrdf.specIntensity += curLayerBrdf.specIntensity * curLayerWeight;
        finalBrdf.specPower     += curLayerBrdf.specPower * curLayerWeight;
    }

    finalBrdf.normal = normalize(finalBrdf.normal);

    float ambientOcclusion = propertiesMap.sample(sam, in.uv).r;
    finalBrdf.ao = ambientOcclusion;

    GBufferFragOut output = PackBrdfProperties(finalBrdf);
#ifdef __METAL_IOS__
    output.gBufferDepth = in.position.z;
#endif
    return output;
}

static float tessFactor(float4x4 viewProjectionMatrix, float projectionYScale, float scale, float3 p0, float3 p1) {
    float3 center = (p0 + p1) * 0.5f;
    float diameter = distance(p0, p1);

    float4 clip = viewProjectionMatrix * float4(center, 1.0f);
    float projectedLength = abs(diameter * projectionYScale / clip.w);

    return max(scale * projectedLength, 1.0f);
}

kernel void TerrainKnl_FillInTesselationFactors(device MTLQuadTessellationFactorsHalf* outVisiblePatchesTessFactorBfr [[buffer(0)]],
                                                device uint32_t* outVisiblePatchIndices [[buffer(2)]],
                                                constant float& tesselationScale [[buffer(3)]],
                                                constant AAPLUniforms& uniforms [[buffer(4)]],
                                                texture2d<float> heightMap [[texture(0)]],
                                                uint2 tid [[thread_position_in_grid]])
{
    float2 u00 = float2((tid.x + 0.f) / TERRAIN_PATCHES, (tid.y + 0.f) / TERRAIN_PATCHES);
    float2 u01 = float2((tid.x + 0.f) / TERRAIN_PATCHES, (tid.y + 1.f) / TERRAIN_PATCHES);
    float2 u10 = float2((tid.x + 1.f) / TERRAIN_PATCHES, (tid.y + 0.f) / TERRAIN_PATCHES);
    float2 u11 = float2((tid.x + 1.f) / TERRAIN_PATCHES, (tid.y + 1.f) / TERRAIN_PATCHES);

    float3 p00 = float3((u00.x - 0.5f) * TERRAIN_SCALE, 0, (u00.y - 0.5f) * TERRAIN_SCALE);
    float3 p01 = float3((u01.x - 0.5f) * TERRAIN_SCALE, 0, (u01.y - 0.5f) * TERRAIN_SCALE);
    float3 p10 = float3((u10.x - 0.5f) * TERRAIN_SCALE, 0, (u10.y - 0.5f) * TERRAIN_SCALE);
    float3 p11 = float3((u11.x - 0.5f) * TERRAIN_SCALE, 0, (u11.y - 0.5f) * TERRAIN_SCALE);

    {
        const uint patchID = tid.x + tid.y * TERRAIN_PATCHES;
        outVisiblePatchIndices [patchID] = patchID;

        constexpr sampler sam(min_filter::linear, mag_filter::linear, mip_filter::none, address::clamp_to_edge);

        p00.y = heightMap.sample(sam, u00).r * TERRAIN_HEIGHT;
        p01.y = heightMap.sample(sam, u01).r * TERRAIN_HEIGHT;
        p10.y = heightMap.sample(sam, u10).r * TERRAIN_HEIGHT;
        p11.y = heightMap.sample(sam, u11).r * TERRAIN_HEIGHT;

        float e0 = tessFactor(uniforms.cameraUniforms.viewProjectionMatrix, uniforms.projectionYScale, tesselationScale, p00, p01);
        float e1 = tessFactor(uniforms.cameraUniforms.viewProjectionMatrix, uniforms.projectionYScale, tesselationScale, p00, p10);
        float e2 = tessFactor(uniforms.cameraUniforms.viewProjectionMatrix, uniforms.projectionYScale, tesselationScale, p10, p11);
        float e3 = tessFactor(uniforms.cameraUniforms.viewProjectionMatrix, uniforms.projectionYScale, tesselationScale, p01, p11);

        outVisiblePatchesTessFactorBfr[patchID].edgeTessellationFactor[0] = e0;
        outVisiblePatchesTessFactorBfr[patchID].edgeTessellationFactor[1] = e1;
        outVisiblePatchesTessFactorBfr[patchID].edgeTessellationFactor[2] = e2;
        outVisiblePatchesTessFactorBfr[patchID].edgeTessellationFactor[3] = e3;

        outVisiblePatchesTessFactorBfr[patchID].insideTessellationFactor[0] = (e1 + e3) * 0.5f;
        outVisiblePatchesTessFactorBfr[patchID].insideTessellationFactor[1] = (e0 + e2) * 0.5f;
    }
}

kernel void TerrainKnl_ComputeNormalsFromHeightmap(texture2d<float> height [[texture(0)]],
                                                   texture2d<float, access::write> normal [[texture(1)]],
                                                   uint2 tid [[thread_position_in_grid]])
{
    constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none,
                          address::clamp_to_edge, coord::pixel);

    float xz_scale = TERRAIN_SCALE / height.get_width();
    float y_scale = TERRAIN_HEIGHT;

    if (tid.x < height.get_width() && tid.y < height.get_height()) {
        float h_up     = height.sample(sam, (float2)(tid + uint2(0, 1))).r;
        float h_down   = height.sample(sam, (float2)(tid - uint2(0, 1))).r;
        float h_right  = height.sample(sam, (float2)(tid + uint2(1, 0))).r;
        float h_left   = height.sample(sam, (float2)(tid - uint2(1, 0))).r;
        float h_center = height.sample(sam, (float2)(tid + uint2(0, 0))).r;

        float3 v_up    = float3( 0,        (h_up    - h_center) * y_scale,  xz_scale);
        float3 v_down  = float3( 0,        (h_down  - h_center) * y_scale, -xz_scale);
        float3 v_right = float3( xz_scale, (h_right - h_center) * y_scale,  0);
        float3 v_left  = float3(-xz_scale, (h_left  - h_center) * y_scale,  0);

        float3 n0 = cross(v_up, v_right);
        float3 n1 = cross(v_left, v_up);
        float3 n2 = cross(v_down, v_left);
        float3 n3 = cross(v_right, v_down);

        float3 n = normalize(n0 + n1 + n2 + n3) * 0.5f + 0.5f;

        normal.write(float4(n.xzy, 1), tid);
    }
}

kernel void TerrainKnl_ComputeOcclusionAndSlopeFromHeightmap(texture2d<float> height [[texture(0)]],
                                                             texture2d<float, access::read_write> propTexture [[texture(1)]],
                                                             constant float2 *aoSamples [[buffer(0)]],
                                                             constant int & aoSampleCount [[buffer(1)]],
                                                             constant float2 &invSize [[buffer(2)]],
                                                             uint2 tid [[thread_position_in_grid]])
{
    constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none,
                          address::clamp_to_edge);

    float2 uv_center = ((float2)tid + float2(0.5f, 0.5f)) * invSize;
    float aoVal;

    // Generate AO
    {
        float h_center = height.sample(sam, uv_center).r + 0.001f;

        int numVisible = 0;

        float2 uv = uv_center;

        for (int i = 0; i < aoSampleCount; i++) {
            float2 v = aoSamples[i];

            float h = height.sample(sam, uv + v / height.get_width()).r;

            if (h < h_center)
                numVisible++;
        }

        aoVal = (float)numVisible / (float)aoSampleCount;
    }

    float varianceVal;
    // Generate Variance
    {
        const float offset = 3.5f * invSize.x;
        float2 uv = uv_center;

        float center = height.sample(sam, uv).x;

        float total = 0;
        for (int j = -3; j <= 3; ++j)
        {
            for (int i = -3; i <= 3; ++i)
            {
                if (i == 0 && j == 0) continue;

                float sample = height.sample(sam, uv + float2(offset*i, offset*j)).x;

                total += sample - center;
            }
        }
        total = max(total, 0.f);
        total = total / ((7*7)-1) ;
        varianceVal = saturate(total*2);
    }

    float4 oldval = propTexture.read(tid);
    oldval.xy = float2(aoVal, varianceVal);

    propTexture.write(oldval, tid);
}

kernel void TerrainKnl_ClearTexture(texture2d<float, access::write> tex,
                                    uint2 tid [[thread_position_in_grid]])
{
    tex.write(0, tid);
}

kernel void TerrainKnl_UpdateHeightmap(texture2d<float, access::read_write> heightMap   [[texture(0)]],
                                       uint2 tid                                        [[thread_position_in_grid]],
                                       constant float4 &mousePosition                   [[buffer(0)]],
                                       constant AAPLUniforms& globalUniforms            [[buffer(1)]])
{
    float2 world_xz = (float2(tid) / float2(heightMap.get_width(), heightMap.get_width()) - .5f) * TERRAIN_SCALE;
    float displacement = evaluateModificationBrush(world_xz, mousePosition, globalUniforms.brushSize) * 0.008f;
    if (globalUniforms.mouseState.z == 2) displacement *= -1.0;
    float h = heightMap.read(tid).r;
    heightMap.write(h+displacement, tid);
}

kernel void TerrainKnl_CopyChannel1Only(texture2d<float> src [[texture(0)]],
                                        texture2d<float, access::write> dst [[texture(1)]],
                                        uint2 tid [[thread_position_in_grid]])
{
    float r = src.read(tid).r;
    dst.write(r, tid);
}
