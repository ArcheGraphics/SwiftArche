//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <metal_stdlib>
using namespace metal;

#import "MainRenderer_shared.h"
#import "MainRendererUtilities.metal"

static float3 GetWorldPositionAndViewDirFromDepth(uint2 tid, float depth, constant AAPLUniforms& uniforms, thread float3& outViewDirection)
{
    float4 ndc;
    ndc.xy = (float2(tid) + 0.5) * uniforms.invScreenSize;
    ndc.xy = ndc.xy * 2 - 1;
    ndc.y *= -1;

    ndc.z = depth;
    ndc.w = 1;

    float4 worldPosition = uniforms.cameraUniforms.invViewProjectionMatrix * ndc;
    worldPosition.xyz /= worldPosition.w;

    ndc.z = 1.f;
    float4 viewDir = uniforms.cameraUniforms.invOrientationProjectionMatrix * ndc;
    viewDir /= viewDir.w;
    outViewDirection = viewDir.xyz;

    return worldPosition.xyz;
}

float evaluate_shadow(constant AAPLUniforms&   globalUniforms,
                      float3                   worldPosition,
                      float                    eyeDepth,
                      depth2d_array<float>     shadowMap,
                      texture2d<float>         perlinMap)
{
    constexpr sampler sam (min_filter::linear, mag_filter::linear, compare_func::less);

    // Figure out which cascade index we're in; 3 cascades is assumed
    float4 lightSpacePos;
    int     cascadeIndex = 0;
    float   shadow = 1.0;
    for (cascadeIndex = 0; cascadeIndex < 3; cascadeIndex++)
    {
        lightSpacePos = globalUniforms.shadowCameraUniforms[cascadeIndex].viewProjectionMatrix * float4(worldPosition, 1);
        lightSpacePos /= lightSpacePos.w;
        if (all(lightSpacePos.xyz < 1.0) && all(lightSpacePos.xyz > float3(-1,-1,0)))
        {
            shadow = 0.0f;
            float lightSpaceDepth = lightSpacePos.z;
            float2 shadowUv = lightSpacePos.xy * float2(0.5, -0.5) + 0.5;
            for (int j = -1; j <= 1; ++j)
                for (int i = -1; i <= 1; ++i)
                {
                    const float depthBias = -0.0001;
                    float tap = shadowMap.sample_compare(sam, shadowUv, cascadeIndex, lightSpaceDepth + depthBias, int2(i, j));
                    shadow += tap;
                }
            shadow /= 9;
            break;
        }
    }

    // Cloud shadows
    const float time = GAME_TIME*2.2;
    constexpr sampler psamp(min_filter::linear, mag_filter::linear, address::repeat);

    float l0 = smoothstep(0.5, 0.7, perlinMap.sample(psamp, fract(worldPosition.xz/7000.f)-time*0.008, level(0)).x);

    float l1 = smoothstep(0.05, 0.8, perlinMap.sample(psamp, fract(worldPosition.xz/2500.f)-float2(time, time*0.5)*0.03, level(0)).y)*0.2+0.8;

    float l2 = perlinMap.sample(psamp, fract(worldPosition.xz/1000.f)-float2(time*0.5, time)*0.1, level(0)).z *0.15+0.75;

    float cloud = saturate(l0*l1*l2)*0.75;
    cloud = 1.0-cloud;

    shadow = min(shadow, cloud);

    return shadow;
}

struct LightingVtxOut
{
    float4 position [[position]];
};

vertex LightingVtxOut LightingVs(uint vid [[vertex_id]])
{
    const float2 vertices[] =
    {
        float2(-1, -1),
        float2(-1,  3),
        float2( 3, -1)
    };

    LightingVtxOut out;
    out.position = float4(vertices[vid], 1.0, 1.0);
    return out;
}

struct LightingPsOut
{
#ifdef __METAL_IOS__
    float4 backbuffer [[color(2)]];
#else
    float4 backbuffer [[color(0)]];
#endif
};

float4 visualizeModificationBrush(constant AAPLUniforms&   globalUniforms,
                                  float3                   worldPosition,
                                  float4                   mousePosition)
{
    float brush = evaluateModificationBrush(worldPosition.xz, mousePosition, globalUniforms.brushSize);
    float3 color =      globalUniforms.mouseState.z == 2 ? float3(0.9, 0.5, 0.5) :
    globalUniforms.mouseState.z == 1 ? float3(0.5, 0.9, 0.5) : float3(0.5, 0.5, 0.7);

    float waveVisibility = min(brush, (1.f-brush)*20+0.5f);
    return float4(color, waveVisibility * (0.5 + .2 * sin(brush*20.0+GAME_TIME*5.0)));
}

fragment LightingPsOut LightingPs(LightingVtxOut                   in              [[stage_in]],
#ifdef __METAL_IOS__
                                  float4                           gBuffer0Value   [[color (0)]],
                                  float4                           gBuffer1Value   [[color (1)]],
                                  float                            depthValue      [[color (3)]],
#else
                                  texture2d <float, access::read>  gBuffer0        [[texture (0)]],
                                  texture2d <float, access::read>  gBuffer1        [[texture (1)]],
                                  depth2d <float, access::read>    depthBuffer     [[texture (2)]],
#endif
                                  depth2d_array <float>            shadowMap       [[texture (3)]],
                                  texturecube <float>              cubemap         [[texture (4)]],
                                  texture2d <float>                perlinMap       [[texture (5)]],
                                  constant AAPLUniforms&           uniforms        [[buffer  (0)]],
                                  constant float4&                 mouseWorldPos   [[buffer  (1)]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    const uint2 pixelPos = uint2(floor(in.position.xy));

#ifdef __METAL_IOS__
    const float depth = depthValue;
#else
    const float depth = depthBuffer.read(pixelPos);
#endif

    float3 viewDir;
    const float3 worldPosition =
    GetWorldPositionAndViewDirFromDepth(pixelPos, depth, uniforms, viewDir);

    if (depth == 1)
    {
        float3 cubemapColor = cubemap.sample(colorSampler, viewDir, level(0)).xyz;

        LightingPsOut res;
        res.backbuffer = float4(cubemapColor, 1);
        return res;
    }

#ifndef __METAL_IOS__
    float4 gBuffer0Value = gBuffer0.read(pixelPos);
    float4 gBuffer1Value = gBuffer1.read(pixelPos);
#endif
    BrdfProperties brdfProps = UnpackBrdfProperties(gBuffer0Value, gBuffer1Value);

    const float shadowAmount = evaluate_shadow(uniforms, worldPosition, depth, shadowMap, perlinMap);

    // Sun direction is hardcoded since we use a fixed cubemap
    const float3 sunDirection = float3(-1, 0.7, -0.5);

    // How much illumination the current fragment receives
    // - it depends on the normal and whether or not it is shadowed
    const float nDotL = saturate(dot(sunDirection, brdfProps.normal)) * shadowAmount * 1.2;

    // For the ambient color, we'll sample the cubemap. Another approach can be considerered however using have an irradiance map
    // - Note: we don't want to sample too close to the horizon, as the texture becomes very white at altitude 0, due to the haze / scattering
    const float3 ambientDirectionUp = float3(0,1,0);
    const float3 ambientDirectionHoriz = normalize(float3(-sunDirection.x, 0.1, -sunDirection.z));
    const float3 ambientDirection = normalize(mix(ambientDirectionHoriz, ambientDirectionUp, brdfProps.normal.y));
    const float3 ambientColorBase = saturate(cubemap.sample(colorSampler, ambientDirection, level(0)).xyz * 1.5 + 0.1);
    const float3 ambientColor = ambientColorBase * max(0.05, brdfProps.normal.y);

    float3 color = brdfProps.albedo * (ambientColor + float3(nDotL));

    // Add an atmospherics blend; it is absolutely empirical.
    float hazeAmount;
    {
        const float near = 0.992;
        const float far = 1.0;
        const float invFarByNear = 1.0 / (far-near);
        const float approxlinDepth = saturate((depth-near) * invFarByNear);
        hazeAmount = pow(approxlinDepth,10)*0.3;
    }
    const float3 hazeColor = saturate(cubemap.sample(colorSampler, float3(0,1,0)).xyz * 3.0 + 0.1);
    color = mix(color, hazeColor, float3(hazeAmount));

#ifndef __METAL_IOS__
    float4 brush = visualizeModificationBrush(uniforms, worldPosition, mouseWorldPos);
    color = mix(color, brush.xyz, brush.w);
#endif

    LightingPsOut res;
    res.backbuffer = float4(color, 1);
    return res;
}

kernel void mousePositionUpdate(depth2d<float, access::read> depthBuffer [[texture(0)]],
                                constant AAPLUniforms& globalUniforms    [[buffer(0)]],
                                device float4& outWorldPos               [[buffer(1)]],
                                uint2 tid                                [[thread_position_in_grid]])
{
    const uint2 mousePos    = uint2(floor(globalUniforms.mouseState.xy));
    const float mouseDepth  = depthBuffer.read(mousePos);
    float3 viewDir;
    const float3 worldMousePosition = GetWorldPositionAndViewDirFromDepth(mousePos, mouseDepth, globalUniforms, viewDir);
    outWorldPos = float4(worldMousePosition, 666.0);
}
