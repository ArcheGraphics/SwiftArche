//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "shadow_shading.h"
using namespace metal;
#include "../function_constant.h"

// ------------------------------------------------------------------
//  PCF Filtering Tent Functions
// ------------------------------------------------------------------

// Assuming a isoceles right angled triangle of height "triangleHeight" (as drawn below).
// This function return the area of the triangle above the first texel(in Y the first texel).
//
// |\      <-- 45 degree slop isosceles right angled triangle
// | \
// ----    <-- length of this side is "triangleHeight"
// _ _ _ _ <-- texels
float ShadowShading::sampleShadowGetIRTriangleTexelArea(float triangleHeight) {
    return triangleHeight - 0.5;
}

// Assuming a isoceles triangle of 1.5 texels height and 3 texels wide lying on 4 texels.
// This function return the area of the triangle above each of those texels.
//    |    <-- offset from -0.5 to 0.5, 0 meaning triangle is exactly in the center
//   / \   <-- 45 degree slop isosceles triangle (ie tent projected in 2D)
//  /   \
// _ _ _ _ <-- texels
// X Y Z W <-- result indices (in computedArea.xyzw and computedAreaUncut.xyzw)
// Top point at (right,top) in a texel,left bottom point at (middle,middle) in a texel,right bottom point at (middle,middle) in a texel.
void ShadowShading::sampleShadowGetTexelAreasTent3x3(float offset, thread float4& computedArea, thread float4& computedAreaUncut) {
    // Compute the exterior areas,a and h is same.
    float a = offset + 0.5;
    float offsetSquaredHalved = a * a * 0.5;
    computedAreaUncut.x = computedArea.x = offsetSquaredHalved - offset;
    computedAreaUncut.w = computedArea.w = offsetSquaredHalved;

    // Compute the middle areas
    // For Y : We find the area in Y of as if the left section of the isoceles triangle would
    // intersect the axis between Y and Z (ie where offset = 0).
    computedAreaUncut.y = sampleShadowGetIRTriangleTexelArea(1.5 - offset);
    // This area is superior to the one we are looking for if (offset < 0) thus we need to
    // subtract the area of the triangle defined by (0,1.5-offset), (0,1.5+offset), (-offset,1.5).
    float clampedOffsetLeft = min(offset,0.0);
    float areaOfSmallLeftTriangle = clampedOffsetLeft * clampedOffsetLeft;
    computedArea.y = computedAreaUncut.y - areaOfSmallLeftTriangle;

    // We do the same for the Z but with the right part of the isoceles triangle
    computedAreaUncut.z = sampleShadowGetIRTriangleTexelArea(1.5 + offset);
    float clampedOffsetRight = max(offset,0.0);
    float areaOfSmallRightTriangle = clampedOffsetRight * clampedOffsetRight;
    computedArea.z = computedAreaUncut.z - areaOfSmallRightTriangle;
}

// Assuming a isoceles triangle of 2.5 texel height and 5 texels wide lying on 6 texels.
// This function return the weight of each texels area relative to the full triangle area.
//  /       \
// _ _ _ _ _ _ <-- texels
// 0 1 2 3 4 5 <-- computed area indices (in texelsWeights[])
// Top point at (right,top) in a texel,left bottom point at (middle,middle) in a texel,right bottom point at (middle,middle) in a texel.
void ShadowShading::sampleShadowGetTexelWeightsTent5x5(float offset, thread float3& texelsWeightsA, thread float3& texelsWeightsB) {
    float4 areaFrom3texelTriangle;
    float4 areaUncutFrom3texelTriangle;
    sampleShadowGetTexelAreasTent3x3(offset, areaFrom3texelTriangle, areaUncutFrom3texelTriangle);

    // Triangle slope is 45 degree thus we can almost reuse the result of the 3 texel wide computation.
    // the 5 texel wide triangle can be seen as the 3 texel wide one but shifted up by one unit/texel.
    // 0.16 is 1/(the triangle area)
    texelsWeightsA.x = 0.16 * (areaFrom3texelTriangle.x);
    texelsWeightsA.y = 0.16 * (areaUncutFrom3texelTriangle.y);
    texelsWeightsA.z = 0.16 * (areaFrom3texelTriangle.y + 1.0);
    texelsWeightsB.x = 0.16 * (areaFrom3texelTriangle.z + 1.0);
    texelsWeightsB.y = 0.16 * (areaUncutFrom3texelTriangle.z);
    texelsWeightsB.z = 0.16 * (areaFrom3texelTriangle.w);
}

// 5x5 Tent filter (45 degree sloped triangles in U and V)
void ShadowShading::sampleShadowComputeSamplesTent5x5(float4 shadowMapTextureTexelSize, float2 coord,
                                                      thread float* fetchesWeights, thread float2* fetchesUV) {
    // tent base is 5x5 base thus covering from 25 to 36 texels, thus we need 9 bilinear PCF fetches
    float2 tentCenterInTexelSpace = coord.xy * shadowMapTextureTexelSize.zw;
    float2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    float2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based on the area of a 45 degree slop tent above each of them.
    float3 texelsWeightsUA, texelsWeightsUB;
    float3 texelsWeightsVA, texelsWeightsVB;
    sampleShadowGetTexelWeightsTent5x5(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsUA, texelsWeightsUB);
    sampleShadowGetTexelWeightsTent5x5(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsVA, texelsWeightsVB);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    float3 fetchesWeightsU = float3(texelsWeightsUA.xz, texelsWeightsUB.y) + float3(texelsWeightsUA.y, texelsWeightsUB.xz);
    float3 fetchesWeightsV = float3(texelsWeightsVA.xz, texelsWeightsVB.y) + float3(texelsWeightsVA.y, texelsWeightsVB.xz);

    // move the PCF bilinear fetches to respect texels weights
    float3 fetchesOffsetsU = float3(texelsWeightsUA.y, texelsWeightsUB.xz) / fetchesWeightsU.xyz + float3(-2.5,-0.5,1.5);
    float3 fetchesOffsetsV = float3(texelsWeightsVA.y, texelsWeightsVB.xz) / fetchesWeightsV.xyz + float3(-2.5,-0.5,1.5);
    fetchesOffsetsU *= shadowMapTextureTexelSize.xxx;
    fetchesOffsetsV *= shadowMapTextureTexelSize.yyy;

    float2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * shadowMapTextureTexelSize.xy;
    fetchesUV[0] = bilinearFetchOrigin + float2(fetchesOffsetsU.x, fetchesOffsetsV.x);
    fetchesUV[1] = bilinearFetchOrigin + float2(fetchesOffsetsU.y, fetchesOffsetsV.x);
    fetchesUV[2] = bilinearFetchOrigin + float2(fetchesOffsetsU.z, fetchesOffsetsV.x);
    fetchesUV[3] = bilinearFetchOrigin + float2(fetchesOffsetsU.x, fetchesOffsetsV.y);
    fetchesUV[4] = bilinearFetchOrigin + float2(fetchesOffsetsU.y, fetchesOffsetsV.y);
    fetchesUV[5] = bilinearFetchOrigin + float2(fetchesOffsetsU.z, fetchesOffsetsV.y);
    fetchesUV[6] = bilinearFetchOrigin + float2(fetchesOffsetsU.x, fetchesOffsetsV.z);
    fetchesUV[7] = bilinearFetchOrigin + float2(fetchesOffsetsU.y, fetchesOffsetsV.z);
    fetchesUV[8] = bilinearFetchOrigin + float2(fetchesOffsetsU.z, fetchesOffsetsV.z);

    fetchesWeights[0] = fetchesWeightsU.x * fetchesWeightsV.x;
    fetchesWeights[1] = fetchesWeightsU.y * fetchesWeightsV.x;
    fetchesWeights[2] = fetchesWeightsU.z * fetchesWeightsV.x;
    fetchesWeights[3] = fetchesWeightsU.x * fetchesWeightsV.y;
    fetchesWeights[4] = fetchesWeightsU.y * fetchesWeightsV.y;
    fetchesWeights[5] = fetchesWeightsU.z * fetchesWeightsV.y;
    fetchesWeights[6] = fetchesWeightsU.x * fetchesWeightsV.z;
    fetchesWeights[7] = fetchesWeightsU.y * fetchesWeightsV.z;
    fetchesWeights[8] = fetchesWeightsU.z * fetchesWeightsV.z;
}

// MARK: - Sampler
int ShadowShading::computeCascadeIndex(float3 positionWS) {
    float3 fromCenter0 = positionWS - u_shadowSplitSpheres[0].xyz;
    float3 fromCenter1 = positionWS - u_shadowSplitSpheres[1].xyz;
    float3 fromCenter2 = positionWS - u_shadowSplitSpheres[2].xyz;
    float3 fromCenter3 = positionWS - u_shadowSplitSpheres[3].xyz;
    
    float4 comparison = float4(dot(fromCenter0, fromCenter0) < u_shadowSplitSpheres[0].w,
                               dot(fromCenter1, fromCenter1) < u_shadowSplitSpheres[1].w,
                               dot(fromCenter2, fromCenter2) < u_shadowSplitSpheres[2].w,
                               dot(fromCenter3, fromCenter3) < u_shadowSplitSpheres[3].w);
    comparison.yzw = clamp(comparison.yzw - comparison.xyz, 0.0, 1.0);//keep the nearest
    float4 indexCoefficient = float4(4.0, 3.0, 2.0, 1.0);
    int index = 4 - int(dot(comparison, indexCoefficient));
    return index;
}

float ShadowShading::sampleShadowMapFiltered4(float3 shadowCoord, int cascadeIndex) {
    float attenuation;
    float4 attenuation4;
    float2 offset = u_shadowMapSize.xy/2.0;
    float3 shadowCoord0 = shadowCoord + float3(-offset,0.0);
    float3 shadowCoord1 = shadowCoord + float3(offset.x,-offset.y,0.0);
    float3 shadowCoord2 = shadowCoord + float3(-offset.x,offset.y,0.0);
    float3 shadowCoord3 = shadowCoord + float3(offset,0.0);
    attenuation4.x = u_shadowMap.sample_compare(u_shadowMapSampler, shadowCoord0.xy, cascadeIndex, shadowCoord0.z);
    attenuation4.y = u_shadowMap.sample_compare(u_shadowMapSampler, shadowCoord1.xy, cascadeIndex, shadowCoord1.z);
    attenuation4.z = u_shadowMap.sample_compare(u_shadowMapSampler, shadowCoord2.xy, cascadeIndex, shadowCoord2.z);
    attenuation4.w = u_shadowMap.sample_compare(u_shadowMapSampler, shadowCoord3.xy, cascadeIndex, shadowCoord3.z);
    attenuation = dot(attenuation4, float4(0.25));
    return attenuation;
}

float ShadowShading::sampleShadowMapFiltered9(float3 shadowCoord, int cascadeIndex) {
    float attenuation;
    float fetchesWeights[9];
    float2 fetchesUV[9];
    sampleShadowComputeSamplesTent5x5(u_shadowMapSize, shadowCoord.xy, fetchesWeights, fetchesUV);
    attenuation = fetchesWeights[0] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[0].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[1] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[1].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[2] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[2].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[3] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[3].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[4] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[4].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[5] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[5].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[6] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[6].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[7] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[7].xy, cascadeIndex, shadowCoord.z);
    attenuation += fetchesWeights[8] * u_shadowMap.sample_compare(u_shadowMapSampler, fetchesUV[8].xy, cascadeIndex, shadowCoord.z);
    return attenuation;
}

float ShadowShading::sampleShadowMap() {
    // getShadowCoord
    int cascadeIndex = 0;
    if (cascadeCount != 1) {
        cascadeIndex = computeCascadeIndex(v_pos);
    }
    matrix_float4x4 shadowMatrix = u_shadowMatrices[cascadeIndex];
    float4 shadowCoord = shadowMatrix * float4(v_pos, 1.0);
    shadowCoord.xyz /= shadowCoord.w;
    
    float attenuation = 1.0;
    if(shadowCoord.z > 0.0 && shadowCoord.z < 1.0) {
        if (shadowMode == 1) {
            attenuation = u_shadowMap.sample_compare(u_shadowMapSampler, shadowCoord.xy, cascadeIndex, shadowCoord.z);
        }
        
        if (shadowMode == 2) {
            attenuation = sampleShadowMapFiltered4(shadowCoord.xyz, cascadeIndex);
        }
        
        if (shadowMode == 3) {
            attenuation = sampleShadowMapFiltered9(shadowCoord.xyz, cascadeIndex);
        }
        
        attenuation = mix(1.0, attenuation, u_shadowInfo.x);
    }
    return attenuation;
}
