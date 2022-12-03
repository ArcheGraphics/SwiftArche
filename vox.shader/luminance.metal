//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

// Relative luminance for sRGB Primaries.
constant float3 kRec709Luma(.2126f,.7152f,.0722f);
constexpr sampler linearFilterSampler(coord::normalized, address::clamp_to_edge, filter::linear);
// Avoid negative infinity when calculating luminance at a black pixel
constant float kLuminanceEpsilon = .001f;

// Scene Luminance
// log average luminance:
//   average:luminance := exp(avg(log(delta + lum(rgb))))
//   Where
//   lum(rgb) := r * .2126f + g * .7152f + b * .0722f := dot(rgb, float3(.2126f,.7152f,.0722f))
//
// Computing Average Log Luminance will happen in 3 steps:
//   1. Store log(delta + lum(rgb)) for each pixel
//   2. Generate mip chain -> average will be stored in highest mip level
//   3. Sample max mip level and apply exp() for final average luminance result

// Step 1: Store log(delta + lum(rgb))
kernel void logLuminance(texture2d<float, access::sample> input [[texture(0)]],
                         texture2d<float, access::write> output [[texture(1)]],
                         uint3 tpig [[ thread_position_in_grid ]]) {
    float2 inputuv = float2(tpig.xy) / float2(output.get_width(), output.get_height());
    float luminance = dot(input.sample(linearFilterSampler, inputuv).rgb, kRec709Luma) + kLuminanceEpsilon;
    output.write(log(luminance), tpig.xy);
}
