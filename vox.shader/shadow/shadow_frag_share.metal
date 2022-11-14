//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <simd/simd.h>
#include <metal_stdlib>
using namespace metal;
#include "shadow_sample_tent.h"
#include "../function_constant.h"

int computeCascadeIndex(float3 positionWS, device float4* u_shadowSplitSpheres) {
    float3 fromCenter0 = positionWS - u_shadowSplitSpheres[0].xyz;
    float3 fromCenter1 = positionWS - u_shadowSplitSpheres[1].xyz;
    float3 fromCenter2 = positionWS - u_shadowSplitSpheres[2].xyz;
    float3 fromCenter3 = positionWS - u_shadowSplitSpheres[3].xyz;
    
    float4 comparison = float4(dot(fromCenter0, fromCenter0) < u_shadowSplitSpheres[0].w,
                               dot(fromCenter1, fromCenter1) < u_shadowSplitSpheres[1].w,
                               dot(fromCenter2, fromCenter2) < u_shadowSplitSpheres[2].w,
                               dot(fromCenter3, fromCenter3) < u_shadowSplitSpheres[3].w);
    comparison.yzw = clamp(comparison.yzw - comparison.xyz,0.0,1.0);//keep the nearest
    float4 indexCoefficient = float4(4.0,3.0,2.0,1.0);
    int index = 4 - int(dot(comparison, indexCoefficient));
    return index;
}

float3 getShadowCoord(float3 v_pos, device float4* u_shadowSplitSpheres, device matrix_float4x4* u_shadowMatrices) {
    int cascadeIndex = computeCascadeIndex(v_pos, u_shadowSplitSpheres);
    matrix_float4x4 shadowMatrix = u_shadowMatrices[cascadeIndex];
    float4 shadowCoord = shadowMatrix * float4(v_pos, 1.0);
    return shadowCoord.xyz / shadowCoord.w;
}

float sampleShadowMapFiltered4(depth2d<float> shadowMap, sampler s, float3 shadowCoord, float4 shadowMapSize) {
    float attenuation;
    float4 attenuation4;
    float2 offset = shadowMapSize.xy/2.0;
    float3 shadowCoord0 = shadowCoord + float3(-offset,0.0);
    float3 shadowCoord1 = shadowCoord + float3(offset.x,-offset.y,0.0);
    float3 shadowCoord2 = shadowCoord + float3(-offset.x,offset.y,0.0);
    float3 shadowCoord3 = shadowCoord + float3(offset,0.0);
    attenuation4.x = shadowMap.sample_compare(s, shadowCoord0.xy, shadowCoord0.z);
    attenuation4.y = shadowMap.sample_compare(s, shadowCoord1.xy, shadowCoord1.z);
    attenuation4.z = shadowMap.sample_compare(s, shadowCoord2.xy, shadowCoord2.z);
    attenuation4.w = shadowMap.sample_compare(s, shadowCoord3.xy, shadowCoord3.z);
    attenuation = dot(attenuation4, float4(0.25));
    return attenuation;
}

float sampleShadowMapFiltered9(depth2d<float> shadowMap, sampler s, float3 shadowCoord, float4 shadowmapSize) {
    float attenuation;
    float fetchesWeights[9];
    float2 fetchesUV[9];
    sampleShadowComputeSamplesTent5x5(shadowmapSize, shadowCoord.xy, fetchesWeights, fetchesUV);
    attenuation = fetchesWeights[0] * shadowMap.sample_compare(s, fetchesUV[0].xy, shadowCoord.z);
    attenuation += fetchesWeights[1] * shadowMap.sample_compare(s, fetchesUV[1].xy, shadowCoord.z);
    attenuation += fetchesWeights[2] * shadowMap.sample_compare(s, fetchesUV[2].xy, shadowCoord.z);
    attenuation += fetchesWeights[3] * shadowMap.sample_compare(s, fetchesUV[3].xy, shadowCoord.z);
    attenuation += fetchesWeights[4] * shadowMap.sample_compare(s, fetchesUV[4].xy, shadowCoord.z);
    attenuation += fetchesWeights[5] * shadowMap.sample_compare(s, fetchesUV[5].xy, shadowCoord.z);
    attenuation += fetchesWeights[6] * shadowMap.sample_compare(s, fetchesUV[6].xy, shadowCoord.z);
    attenuation += fetchesWeights[7] * shadowMap.sample_compare(s, fetchesUV[7].xy, shadowCoord.z);
    attenuation += fetchesWeights[8] * shadowMap.sample_compare(s, fetchesUV[8].xy, shadowCoord.z);
    return attenuation;
}

float sampleShadowMap(float3 v_pos, device float4* u_shadowSplitSpheres, device matrix_float4x4* u_shadowMatrices,
                      depth2d<float> u_shadowMap, sampler s, float4 u_shadowMapSize, float3 u_shadowInfo) {
    float3 shadowCoord = getShadowCoord(v_pos, u_shadowSplitSpheres, u_shadowMatrices);
    float attenuation = 1.0;
    if(shadowCoord.z > 0.0 && shadowCoord.z < 1.0) {
        if (shadowMode == 1) {
            attenuation = u_shadowMap.sample_compare(s, shadowCoord.xy, shadowCoord.z);
        }
        
        if (shadowMode == 2) {
            attenuation = sampleShadowMapFiltered4(u_shadowMap, s, shadowCoord, u_shadowMapSize);
        }
        
        if (shadowMode == 3) {
            attenuation = sampleShadowMapFiltered9(u_shadowMap, s, shadowCoord, u_shadowMapSize);
        }
        
        attenuation = mix(1.0, attenuation, u_shadowInfo.x);
    }
    return attenuation;
}
