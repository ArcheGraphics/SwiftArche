//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;

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
float sampleShadowGetIRTriangleTexelArea(float triangleHeight);

// Assuming a isoceles triangle of 1.5 texels height and 3 texels wide lying on 4 texels.
// This function return the area of the triangle above each of those texels.
//    |    <-- offset from -0.5 to 0.5, 0 meaning triangle is exactly in the center
//   / \   <-- 45 degree slop isosceles triangle (ie tent projected in 2D)
//  /   \
// _ _ _ _ <-- texels
// X Y Z W <-- result indices (in computedArea.xyzw and computedAreaUncut.xyzw)
// Top point at (right,top) in a texel,left bottom point at (middle,middle) in a texel,right bottom point at (middle,middle) in a texel.
void sampleShadowGetTexelAreasTent3x3(float offset, thread float4& computedArea, thread float4& computedAreaUncut);

// Assuming a isoceles triangle of 2.5 texel height and 5 texels wide lying on 6 texels.
// This function return the weight of each texels area relative to the full triangle area.
//  /       \
// _ _ _ _ _ _ <-- texels
// 0 1 2 3 4 5 <-- computed area indices (in texelsWeights[])
// Top point at (right,top) in a texel,left bottom point at (middle,middle) in a texel,right bottom point at (middle,middle) in a texel.
void sampleShadowGetTexelWeightsTent5x5(float offset, thread float3& texelsWeightsA, thread float3& texelsWeightsB);

// 5x5 Tent filter (45 degree sloped triangles in U and V)
void sampleShadowComputeSamplesTent5x5(float4 shadowMapTextureTexelSize, float2 coord, thread float* fetchesWeights, thread float2* fetchesUV);
