//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "function_constant.h"
#include "arguments.h"

// Notes on the math for the following tonemapping operators:
//
// The following operators are defined in terms of luminance, therefore some work must be done
// to determine the final color's scale factor.
//
// Operator represents the input color as vector S and luminance vector R, then computes input
// color luminance L by calculating the dot product of S and R:
//
//   L = S・R
//
// Using L, operator calculates the desired luminance L' using the tonemapping operator T(x) such that:
//
//   L' = T(L)
//
// Operator determines the scalar value K such that:
//
//  KS・R = L'
//
// By leveraging the scalar multiplication property of dot products, this is rewritten as:
//
//   K(S・R) = L'
//
// Substituting L, given it's initial definition:
//
//   KL = L'
//
// Thus
//
//   K = L' / L
//
// For any tone mapping operator T(x) which operates on Luminance, the color scaling factor K is:
//
//   K = T(L) / L

// Relative luminance for sRGB Primaries.
constant float3 kRec709Luma(.2126f,.7152f,.0722f);
// Avoid negative infinity when calculating luminance at a black pixel
constant float kLuminanceEpsilon = .001f;

// Equation 1
float3 RinehardOperator(float3 srcColor, float luminanceScale) {
    float luminance = dot(srcColor, ::kRec709Luma) + kLuminanceEpsilon;
    float targetLuminance = 1.f / (1.f + luminance);
    return srcColor * targetLuminance * luminanceScale;
}

// Equation 2
float3 RinehardExOperator(float3 srcColor, half luminanceWhitePoint, float luminanceScale) {
    float luminance = dot(srcColor, ::kRec709Luma) + kLuminanceEpsilon;
    float targetLuminance = luminance * (1.f + (luminance / (luminanceWhitePoint * luminanceWhitePoint)));
    targetLuminance /= 1.f + luminance;
    targetLuminance *= luminanceScale;
    return srcColor * (targetLuminance / luminance);
}

// The standard ACES tonemap function
float3 toneMapACES(float3 x) {
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return saturate((x*(a*x+b))/(x*(c*x+d)+e));
}

//Sample high level mipmap and apply exp()
float keyExposureCoefficient(float averageLogLuminance, float key) {
    return key / exp(averageLogLuminance);
}

// Manual exposure ignores average luminance and, instead, applies
// a direct pow function
float manualExposureCoefficient(float exposureValue) {
    return pow(2.f, exposureValue) - 1.0;
}

kernel void postprocess_merge(texture2d<float, access::read> framebufferInput [[ texture(0) ]],
                              texture2d<float, access::write> framebufferOutput [[ texture(1) ]],
                              texture2d<float> logLuminanceIn [[texture(2), function_constant(isAutoExposure)]],
                              constant PostprocessData& u_postprocess [[buffer(0)]],
                              uint3 tpig [[ thread_position_in_grid ]]) {
    float exposureCoefficient = 1.f;
    if (isAutoExposure) {
        constexpr sampler mipSampler(filter::linear, mip_filter::linear, lod_clamp(MAXFLOAT,MAXFLOAT));
        float2 texCoord = float2(tpig.xy) / float2(framebufferInput.get_width(), framebufferInput.get_height());
        exposureCoefficient = keyExposureCoefficient(logLuminanceIn.sample(mipSampler, texCoord).r, u_postprocess.exposureKey);
    } else {
        exposureCoefficient = manualExposureCoefficient(u_postprocess.manualExposureValue);
    }
    
    // ACES tonemapping
    float4 color = framebufferInput.read(tpig.xy);
    color.rgb = toneMapACES( color.rgb * exposureCoefficient );
    
    // gamma correction
    framebufferOutput.write(float4(pow(color.rgb, float3(1.0 / 2.2)), color.a), tpig.xy);
}
