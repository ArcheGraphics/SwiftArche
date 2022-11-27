//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "function_constant.h"

// https://learnopengl.com/PBR/IBL/Specular-IBL
// Hammersley
float radicalInverse_VdC(uint bits) {
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
    bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
    bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
    bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
    return float(bits) * 2.3283064365386963e-10; // / 0x100000000
}

float2 hammersley(uint i, uint N) {
    return float2(float(i)/float(N), radicalInverse_VdC(i));
}

float3 importanceSampleGGX(float2 Xi, float3 N, float roughness) {
    float a = roughness * roughness;

    float phi = 2.0 * M_PI_F * Xi.x;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a*a - 1.0) * Xi.y));
    float sinTheta = sqrt(1.0 - cosTheta*cosTheta);

    // from spherical coordinates to cartesian coordinates
    float3 H;
    H.x = cos(phi) * sinTheta;
    H.y = sin(phi) * sinTheta;
    H.z = cosTheta;

    // from tangent-space vector to world-space sample vector
    float3 up        = abs(N.z) < 0.999 ? float3(0.0, 0.0, 1.0) : float3(1.0, 0.0, 0.0);
    float3 tangent   = normalize(cross(up, N));
    float3 bitangent = cross(N, tangent);

    float3 sampleVec = tangent * H.x + bitangent * H.y + N * H.z;
    return normalize(sampleVec);
}

float pow2(const float x) {
    return x * x;
}

float4 RGBEToLinear(float4 value) {
    return float4( value.rgb * exp2( value.a * 255.0 - 128.0 ), 1.0 );
}

float4 RGBMToLinear(float4 value, float maxRange) {
    return float4( value.rgb * value.a * maxRange, 1.0 );
}

float4 gammaToLinear(float4 srgbIn){
    return float4( pow(srgbIn.rgb, float3(2.2)), srgbIn.a);
}

float4 toLinear(float4 color){
    float4 linear = float4(0.0);
    if (DECODE_MODE == 0)
        linear = color;
    else if (DECODE_MODE == 1)
        linear = gammaToLinear(color);
    else if (DECODE_MODE == 2)
        linear = RGBEToLinear(color);
    else if (DECODE_MODE == 3)
        linear = RGBMToLinear(color, 5.0);

    return linear;
}

float4 linearToRGBE(float4 value) {
    float maxComponent = max( max( value.r, value.g ), value.b );
    float fExp = clamp( ceil( log2( maxComponent ) ), -128.0, 127.0 );
    return float4( value.rgb / exp2( fExp ), ( fExp + 128.0 ) / 255.0 );
}


float4 LinearToRGBM(float4 value, float maxRange) {
    float maxRGB = max( value.r, max( value.g, value.b ) );
    float M = clamp( maxRGB / maxRange, 0.0, 1.0 );
    M = ceil( M * 255.0 ) / 255.0;
    return float4( value.rgb / ( M * maxRange ), M );
}

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float D_GGX(const float alpha, const float dotNH) {

    float a2 = pow2( alpha );

    float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0; // avoid alpha = 0 with dotNH = 1

    return M_1_PI_F * a2 / pow2( denom );
}

float3 specular(float3 N, float lodRoughness, float u_textureSize, texturecube<float> environmentMap) {
    float3 R = N;
    float3 V = R;

    float totalWeight = 0.0;
    float3 prefilteredColor = float3(0.0);

    const uint SAMPLE_COUNT = 4096u;
    for(uint i = 0u; i < SAMPLE_COUNT; ++i) {
        float2 Xi = hammersley(i, SAMPLE_COUNT);
        float3 H  = importanceSampleGGX(Xi, N, lodRoughness);
        float3 L  = normalize(2.0 * dot(V, H) * H - V);

        float NdotL = max(dot(N, L), 0.0);
        constexpr sampler EnvMapSampler(filter::linear);

        if(NdotL > 0.0) {
            float dotNH = dot(N,H);
            float D   = D_GGX(lodRoughness, dotNH);
            float pdf = (D * dotNH / (4.0 * dotNH)) + 0.0001;
            float saTexel  = 4.0 * M_PI_F / (6.0 * u_textureSize * u_textureSize);
            float saSample = 1.0 / (float(SAMPLE_COUNT) * pdf + 0.0001);
            float mipLevel = lodRoughness == 0.0 ? 0.0 : 0.5 * log2(saSample / saTexel);
            
            float4 samplerColor = environmentMap.sample(EnvMapSampler, L, level(mipLevel));
            float3 linearColor = toLinear(samplerColor).rgb;

            prefilteredColor += linearColor * NdotL;
            totalWeight      += NdotL;
        }
    }
    prefilteredColor = prefilteredColor / totalWeight;
    return prefilteredColor;
}

kernel void build_specular(texturecube<float, access::sample> input [[ texture(0) ]],
                           texturecube<float, access::write> output [[ texture(1) ]],
                           constant float &lod_roughness [[ buffer(0) ]],
                           uint3 tpig [[ thread_position_in_grid ]]) {
    float inputWidth = input.get_width();
    float width = output.get_width();
    float scale = inputWidth / width;
    uint face = tpig.z;
    float2 inputuv = float2(tpig.xy) / inputWidth;

    float cx = inputuv.x * 2. - 1.;
    float cy = inputuv.y * 2. - 1.;

    float3 dir = float3(0.);
    if (face == 0.) { // PX
        dir = float3( 1.,  cy, -cx);
    }
    else if (face == 1.) { // NX
        dir = float3(-1.,  cy,  cx);
    }
    else if (face == 2.) { // PY
        dir = float3( cx,  1., -cy);
    }
    else if (face == 3.) { // NY
        dir = float3( cx, -1.,  cy);
    }
    else if (face == 4.) { // PZ
        dir = float3( cx,  cy,  1.);
    }
    else if (face == 5.) { // NZ
        dir = float3(-cx,  cy, -1.);
    }
    dir = normalize(dir);
    
    float4 color;
    if (lod_roughness == 0.) {
        constexpr sampler s(filter::linear);
        color = toLinear(input.sample(s, dir));
    } else {
        float3 integratedBRDF = specular(dir, lod_roughness, inputWidth, input);
        color = float4(integratedBRDF, 1.);
    }
    color = LinearToRGBM(color, 5.0);

    uint2 outputuv = uint2(tpig.x/scale, tpig.y/scale);
    output.write(color, outputuv, face);
}