//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>

typedef enum {
    Position = 0,
    Normal = 1,
    UV_0 = 2,
    Tangent = 3,
    Bitangent = 4,
    Color_0 = 5,
    Weights_0 = 6,
    Joints_0 = 7,
    UV_1 = 8,
    UV_2 = 9,
    UV_3 = 10,
    UV_4 = 11,
    UV_5 = 12,
    UV_6 = 13,
    UV_7 = 14,
} Attributes;

struct EnvMapLight {
    vector_float3 diffuse;
    float diffuseIntensity;
    float specularIntensity;
    int mipMapLevel;
    matrix_float4x4 transformMatrix;
};

struct PointLightData {
    vector_float3 color;
    vector_float3 position;
    float distance;
};

struct SpotLightData {
    vector_float3 color;
    vector_float3 position;
    vector_float3 direction;
    float distance;
    float angleCos;
    float penumbraCos;
};

struct DirectLightData {
    vector_float3 color;
    vector_float3 direction;
};