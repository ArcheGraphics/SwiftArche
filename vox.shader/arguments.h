//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>
#import "type_common.h"

using namespace metal;

struct BaseMaterial {
    float alphaCutoff [[id(0)]];
    float4 tilingOffset [[id(1)]];
};

struct UnlitMaterial {
    float4 u_baseColor [[id(1)]];
    sampler u_baseSampler [[id(2)]];
    texture2d<float> u_baseTexture [[id(3)]];
};

struct PBRMaterial {
    vector_float4 baseColor [[id(0)]];

    vector_float4 emissiveColor [[id(1)]];
    float normalTextureIntensity [[id(2)]];

    float occlusionTextureIntensity [[id(3)]];
    int occlusionTextureCoord [[id(4)]];
    float clearCoat [[id(5)]];
    float clearCoatRoughness [[id(6)]];
    
    float metallic [[id(7)]];
    float roughness [[id(8)]];

    vector_float4 specularColor [[id(9)]];
    float glossiness [[id(10)]];
    
    texture2d<float> u_baseTexture [[id(11)]];
    sampler u_baseSampler [[id(12)]];
    texture2d<float> u_normalTexture [[id(13)]];
    sampler u_normalSampler [[id(14)]];
    texture2d<float> u_emissiveTexture [[id(15)]];
    sampler u_emissiveSampler [[id(16)]];
    texture2d<float> u_roughnessMetallicTexture [[id(17)]];
    sampler u_roughnessMetallicSampler [[id(18)]];
    texture2d<float> u_specularGlossinessTexture [[id(19)]];
    sampler u_specularGlossineseSampler [[id(20)]];
    texture2d<float> u_occlusionTexture [[id(21)]];
    sampler u_occlusionSampler [[id(22)]];
    texture2d<float> u_clearCoatTexture [[id(23)]];
    sampler u_clearCoatSampler [[id(24)]];
    texture2d<float> u_clearCoatNormalTexture [[id(25)]];
    sampler u_clearCoatNormalSampler [[id(26)]];
    texture2d<float> u_clearCoatRoughnessTexture [[id(27)]];
    sampler u_clearCoatRoughnessSampler [[id(28)]];
};

// MARK: - Light
struct EnvMapLight {
    vector_float4 diffuse [[id(0)]];
    int mipMapLevel [[id(1)]];
    float diffuseIntensity [[id(2)]];
    float specularIntensity [[id(3)]];
    
    constant float *u_env_sh [[id(4)]];
    texturecube<float> u_env_specularTexture [[id(5)]];
    sampler u_env_specularSampler [[id(6)]];
};

struct PostprocessData {
    float manualExposureValue [[id(0)]];
    float exposureKey [[id(1)]];
};

struct FogData {
    vector_float4 color [[id(0)]];
    vector_float4 params [[id(2)]];
};
