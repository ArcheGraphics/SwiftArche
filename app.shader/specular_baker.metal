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
        constexpr sampler EnvMapSampler(mip_filter::linear, filter::linear);

        if(NdotL > 0.0) {
            float dotNH = dot(N,H);
            float D   = D_GGX(lodRoughness, dotNH);
            float pdf = (D * dotNH / (4.0 * dotNH)) + 0.0001;
            float saTexel  = 4.0 * M_PI_F / (6.0 * u_textureSize * u_textureSize);
            float saSample = 1.0 / (float(SAMPLE_COUNT) * pdf + 0.0001);
            float mipLevel = lodRoughness == 0.0 ? 0.0 : 0.5 * log2(saSample / saTexel);
            
            float4 samplerColor = environmentMap.sample(EnvMapSampler, L, level(mipLevel));
            float3 linearColor = samplerColor.rgb;

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

    float u = 2.0 * inputuv.x - 1.0;
    float v = -2.0 * inputuv.y + 1.0;

    float3 direction;
    switch(face) {
        case 0:
            direction = float3(1.0, v, -u);
            break;
        case 1:
            direction = float3(-1.0, v, u);
            break;
        case 2:
            direction = float3(u, 1.0, -v);
            break;
        case 3:
            direction = float3(u, -1.0, v);
            break;
        case 4:
            direction = float3(u, v, 1.0);
            break;
        case 5:
            direction = float3(-u, v, -1.0);
            break;
    }
    direction = normalize(direction);
    
    float4 color;
    if (lod_roughness == 0.) {
        constexpr sampler s(mip_filter::linear, filter::linear);
        color = input.sample(s, direction);
    } else {
        float3 integratedBRDF = specular(direction, lod_roughness, inputWidth, input);
        color = float4(integratedBRDF, 1.);
    }

    uint2 outputuv = uint2(tpig.x/scale, tpig.y/scale);
    output.write(color, outputuv, face);
}
