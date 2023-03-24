//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "ShaderCommon.h"

#if USE_SCATTERING_VOLUME

constant bool gUseLightCluster         [[function_constant(XFunctionConstIndexLightCluster)]];

constant bool gUseRasterizationRate    [[function_constant(XFunctionConstIndexRasterizationRate)]];

constant uint gLightCullingTileSize    [[function_constant(XFunctionConstIndexLightCullingTileSize)]];

constant uint gLightClusteringTileSize [[function_constant(XFunctionConstIndexLightClusteringTileSize)]];

// Calculate scattering due to exponential fog based on height.
float computeExpHeightFog(float worldPosY, float offset, float falloff)
{
    return saturate(exp(-falloff * max(0.0f, worldPosY + offset)));
}

float applyGlobalNoise(float density, float3 worldPosition, float depth,
                       texture3d<float, access::sample> perlinNoise, float3 globalNoiseOffset,
                       bool useDetailNoise)
{
    constexpr sampler linearSamplerRepeat(mip_filter::linear, filter::linear, address::repeat);

    float3 noisePos = worldPosition + globalNoiseOffset; // apply wind

    const float baseNoiseScale = 1.0f/16.0f;

    float noiseDensity = perlinNoise.sample(linearSamplerRepeat, noisePos * baseNoiseScale).r;

    if(useDetailNoise)
    {
        const float detailNoiseScale = 1.0f/2.0f;
        const float detailNoiseAmplitude = 1.0f;

        noiseDensity += perlinNoise.sample(linearSamplerRepeat, noisePos * detailNoiseScale).r * detailNoiseAmplitude;
        noiseDensity /= (1.0f + detailNoiseAmplitude);
    }

    noiseDensity = smoothstep(0.3f, 0.7f, noiseDensity);
    noiseDensity *= noiseDensity;

    const float noiseFadeStart  = 20.0f;
    const float noiseFadeLength = 10.0f;

    // Used to maintain similar density compared to uniform density.
    const float noiseMult       = 2.0f;

    // Apply noise density with distance fade.
    density *= mix(noiseDensity * noiseMult, 1.0f, saturate(max(0.0f, depth - noiseFadeStart)/noiseFadeLength));

    return density;
}

// Schlick phase function for absorption.
float schlickPhase(float cosTheta, float g)
{
    //float k = 1.55f * g - 0.55f * g * g * g;
    float k = g;

    float x = (1.0f + k * cosTheta);

    return (1.0f - k * k) / (4.0f * M_PI_F * x * x);
}

// Calculates the scattering for a point light.
float3 calculateLocalLightScattering(float3 position,
                                     XPointLightData light,
                                     float localLightIntensity,
                                     float3 viewDir,
                                     float g)
{
    float3 lightVector = light.posSqrRadius.xyz - position;

    if(dot(lightVector, lightVector) > light.posSqrRadius.w)
        return 0.0f;

    float attenuation = getDistanceAttenuation(lightVector, 1.0/light.posSqrRadius.w);

    const float phase = schlickPhase(-dot(normalize(lightVector), viewDir), g);

    return phase * light.color.xyz * M_PI_F * localLightIntensity * attenuation;
}

// Calculates the scattering for a spot light.
float3 calculateLocalSpotLightScattering(float3 position,
                                         XSpotLightData light,
                                         float localLightIntensity,
                                         float3 viewDir,
                                         float g
#if USE_SPOT_LIGHT_SHADOWS
                                         , uint lightIdx
                                         , depth2d_array<float> spotShadowMaps
#endif
                                         )
{
    float3 lightVector = light.posAndHeight.xyz - position;
    float3 lightForward = light.dirAndOuterAngle.xyz;

    float cosAngle = light.dirAndOuterAngle.w;
    float3 lightDirection = normalize(lightVector);

    bool distCutoff = dot(-lightVector, lightDirection) > light.posAndHeight.w;
    bool angleCutoff = dot(-lightDirection, lightForward) < cosAngle;
    if( distCutoff || angleCutoff )
        return 0.0;

    float sqrDist = dot(lightVector, lightVector);
    if(sqrDist <= 0.01f)
        return 0.0f; // prevent scattering leaking inside the "light bulb"

    float attenuation = getDistanceAttenuation(lightVector, 1.0/(light.posAndHeight.w * light.posAndHeight.w));
    attenuation *= getAngleAttenuation(lightForward, -lightDirection, light.dirAndOuterAngle.w, light.colorAndInnerAngle.w);

    float shadow = 1.0;
#if USE_SPOT_LIGHT_SHADOWS
    {
        constexpr sampler compareSampler (min_filter::linear, mag_filter::linear, compare_func::less, address::clamp_to_edge);

        float4 lightSpacePos = light.viewProjMatrix * float4(position.xyz, 1);
        lightSpacePos /= lightSpacePos.w;

        float lightSpaceDepth = lightSpacePos.z - SPOT_SHADOW_DEPTH_BIAS;
        float2 shadowUv = lightSpacePos.xy * float2(0.5, -0.5) + 0.5;
        shadow = spotShadowMaps.sample_compare(compareSampler, shadowUv, lightIdx, lightSpaceDepth);
    }
#endif

    const float phase = schlickPhase(-dot(lightDirection, viewDir), g);

    //according to Moving Frostbite to PBR, intensity spot = 4.0 * intensity point
    return phase * 4.0 * light.colorAndInnerAngle.xyz * M_PI_F * localLightIntensity * attenuation * shadow;
}

// Accumulates the scattering from the sun and the local lights, plus a temporal
//  reprojection of the scattering data from the previous frame.
#if LOCAL_LIGHT_SCATTERING
template <typename PointLightDataArray, typename SpotLightDataArray, typename IndexArray>
#endif
static float4 scattering(uint3 coordinates,
                         float2 texCoord,
                         constant XFrameConstants & frameData,
                         constant XCameraParams & cameraParams,
#if LOCAL_LIGHT_SCATTERING
                         PointLightDataArray pointLightBuffer,
                         SpotLightDataArray spotLightBuffer,
                         IndexArray pointLightIndices,
                         IndexArray spotLightIndices,
#endif
                         texture3d<float, access::sample> prev,
                         texture2d<float, access::read> noiseTexture,
                         texture3d<float, access::sample> perlinNoise,
                         depth2d_array<float, access::sample> shadowMap
#if USE_SPOT_LIGHT_SHADOWS
                         , depth2d_array<float> spotShadowMaps
#endif
                         )
{
    constexpr sampler linearSampler(mip_filter::linear, filter::linear, address::clamp_to_edge);

    float jitter = noiseTexture.read(coordinates.xy % 64).x;
    jitter = goldenRatio(jitter, frameData.frameCounter);
    jitter = (jitter * 2.0f - 1.0f) * 0.5f;

    //jitter = 0.0f;

    float depth         = scatterSliceToZ(coordinates.z + 0.5f);
    float depthJittered = scatterSliceToZ(coordinates.z + 0.5f + jitter);

    float3 farWorldPosition = worldPositionForTexcoord(texCoord, 1.0f, cameraParams).xyz;
    float3 eyeRay = (farWorldPosition - cameraParams.invViewMatrix[3].xyz);
    float3 viewDir = normalize(eyeRay);

    float3 worldPosition            = cameraParams.invViewMatrix[3].xyz + eyeRay * depth * frameData.oneOverFarDistance;
    float3 worldPositionJittered    = cameraParams.invViewMatrix[3].xyz + eyeRay * depthJittered * frameData.oneOverFarDistance;

    uint cascadeIndex;
    float shadow = evaluateCascadeShadows(frameData, worldPositionJittered.xyz, shadowMap, cascadeIndex, false);

    const float expHeightFogScale = 0.01f;
    const float g = 0.3f;

    float absorptionCoeff = 0.01f;
    float scatteringCoeff = 0.01f + computeExpHeightFog(worldPositionJittered.y, 10.0f, 0.5f) * expHeightFogScale;

    scatteringCoeff = applyGlobalNoise(scatteringCoeff, worldPositionJittered, depthJittered,
                                       perlinNoise, frameData.globalNoiseOffset, true);

    scatteringCoeff *= frameData.scatterScale;

    float extinction = absorptionCoeff + scatteringCoeff;

    float3 scattering = frameData.skyColor; // ambient

    {
        // Direct light.
        scattering += frameData.sunColor * M_PI_F * shadow * schlickPhase(-dot(frameData.sunDirection, viewDir), g);
    }

#if LOCAL_LIGHT_SCATTERING
    uint perTilePointLightCount = pointLightIndices[0];

    for(uint i = 0; i < perTilePointLightCount; i++)
    {
        uint lightIdx = pointLightIndices[i+1];
        scattering += calculateLocalLightScattering(worldPositionJittered, pointLightBuffer[lightIdx], frameData.localLightIntensity, viewDir, g);
    }

    uint perTileSpotLightCount = spotLightIndices[0];

    for(uint i = 0; i < perTileSpotLightCount; i++)
    {
        uint lightIdx = spotLightIndices[i+1];
        scattering += calculateLocalSpotLightScattering(worldPositionJittered, spotLightBuffer[lightIdx], frameData.localLightIntensity, viewDir, g
#if USE_SPOT_LIGHT_SHADOWS
                                                        , lightIdx, spotShadowMaps
#endif
                                                        );
    }
#endif

    float4 current = float4(scattering * scatteringCoeff, extinction);
    if (!is_null_texture(prev))
    {
        float4 prevPos = frameData.prevViewProjectionMatrix * float4(worldPosition, 1.0f);
        prevPos.xyz /= prevPos.w;

        float2 prevUV = prevPos.xy * float2(0.5f, -0.5f) + 0.5f;

        float prevScatterDepth = saturate(zToScatterDepth(prevPos.w));

        float4 prevScattering = prev.sample(linearSampler, float3(prevUV, prevScatterDepth));

        float blendFactor = 0.85f;

        if(any(abs(prevPos.xy) > 1.0f))
            blendFactor = 0.0f;

        current.rgba = mix(current.rgba, prevScattering.rgba, blendFactor);
    }

    return current;
}

// Compute kernel for scattering.
kernel void kernelScattering(uint3 coordinates  [[thread_position_in_grid]],

                             constant XFrameConstants & frameData        [[buffer(XBufferIndexFrameData)]],
                             constant XCameraParams & cameraParams       [[buffer(XBufferIndexCameraParams)]],
                             constant rasterization_rate_map_data * rrData  [[buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate)]],
#if LOCAL_LIGHT_SCATTERING
                             device XPointLightData * pointLightBuffer   [[ buffer(XBufferIndexPointLights) ]],
                             device XSpotLightData * spotLightBuffer     [[ buffer(XBufferIndexSpotLights) ]],
                             device uint8_t * pointLightIndices             [[ buffer(XBufferIndexPointLightIndices) ]],
                             device uint8_t * spotLightIndices              [[ buffer(XBufferIndexSpotLightIndices) ]],
#endif
                             texture3d<float, access::write> output         [[texture(0)]],
                             texture3d<float, access::sample> prev          [[texture(1)]],
                             texture2d<float, access::read> noiseTexture    [[texture(2)]],
                             texture3d<float, access::sample> perlinNoise   [[texture(3)]],
                             depth2d_array<float, access::sample> shadowMap [[texture(4)]]
#if USE_SPOT_LIGHT_SHADOWS
                             , depth2d_array<float> spotShadowMaps          [[texture(5)]]
#endif
                             )
{
    const float2 outputCoordNorm = 1.0f / float2(output.get_width(), output.get_height());

    if(any(coordinates.xy >= uint2(output.get_width(), output.get_height())))
       return;

    float2 texCoord = (float2)coordinates.xy;
    texCoord += 0.5f;
    texCoord.xy *= outputCoordNorm;

#if LOCAL_LIGHT_SCATTERING
    uint tileIdx;
    if (gUseLightCluster)
    {
#if SUPPORT_RASTERIZATION_RATE
        if (gUseRasterizationRate)
        {
            rasterization_rate_map_decoder decoder(*rrData);
            float2 physicalPos = decoder.map_screen_to_physical_coordinates(texCoord * frameData.screenSize);
            uint tileX = physicalPos.x / gLightClusteringTileSize;
            uint tileY = physicalPos.y / gLightClusteringTileSize;
            uint cluster = coordinates.z;

            tileIdx = (tileX + frameData.lightIndicesParams.y * tileY + cluster * frameData.lightIndicesParams.z) * MAX_LIGHTS_PER_CLUSTER;
        }
        else
#endif
        {
            uint tileX = texCoord.x * frameData.screenSize.x / gLightClusteringTileSize;
            uint tileY = texCoord.y * frameData.screenSize.y / gLightClusteringTileSize;
            uint cluster = coordinates.z;

            tileIdx = (tileX + frameData.lightIndicesParams.y * tileY + cluster * frameData.lightIndicesParams.z) * MAX_LIGHTS_PER_CLUSTER;
        }
    }
    else
    {
#if SUPPORT_RASTERIZATION_RATE
        if (gUseRasterizationRate)
        {
            rasterization_rate_map_decoder decoder(*rrData);
            float2 physicalPos = decoder.map_screen_to_physical_coordinates(texCoord * frameData.screenSize);
            uint tileX = physicalPos.x / gLightCullingTileSize;
            uint tileY = physicalPos.y / gLightCullingTileSize;

            tileIdx = (tileX + frameData.lightIndicesParams.x * tileY) * MAX_LIGHTS_PER_TILE;
        }
        else
#endif
        {
            uint tileX = texCoord.x * frameData.screenSize.x / gLightCullingTileSize;
            uint tileY = texCoord.y * frameData.screenSize.y / gLightCullingTileSize;

            tileIdx = (tileX + frameData.lightIndicesParams.x * tileY) * MAX_LIGHTS_PER_TILE;
        }
    }

    pointLightIndices += tileIdx;
    spotLightIndices += tileIdx;
#endif

    float4 scatter = scattering(coordinates, texCoord, frameData, cameraParams,
#if LOCAL_LIGHT_SCATTERING
                                pointLightBuffer, spotLightBuffer, pointLightIndices, spotLightIndices,
#endif
                                prev, noiseTexture, perlinNoise, shadowMap
#if USE_SPOT_LIGHT_SHADOWS
                                , spotShadowMaps
#endif
                                );

    output.write(scatter, coordinates);
}

// Compute kernel for scattering accumulation.
kernel void kernelAccumulateScattering(uint2 coordinates                        [[thread_position_in_grid]],
                                       constant XFrameConstants & frameData  [[buffer(XBufferIndexFrameData)]],
                                       texture3d<float, access::write> output   [[texture(0)]],
                                       texture3d<float, access::read> input     [[texture(1)]] )
{
    float4 accum = float4(0.0f, 0.0f, 0.0f, 1.0f);

    float d0 = 0.0f;

    for(int i = 0; i < SCATTERING_VOLUME_DEPTH; ++i)
    {
        float d1 = scatterSliceToZ(i + 0.5f);
        float thickness = d1 - d0;
        d0 = d1;

        float4 scattering = input.read(uint3(coordinates, i));

        float t = exp(-scattering.a * thickness);

        // apply transmittance to current sample
        scattering.rgb = (scattering.rgb - scattering.rgb * t) / max(scattering.a, 0.00001f);

        accum.rgb += scattering.rgb * accum.a;
        accum.a *= t;

        output.write(accum, uint3(coordinates, i));
    }
}
#endif
