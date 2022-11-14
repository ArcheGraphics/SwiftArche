//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "function_constant.h"

struct DirectLight {
    float3 color;
    float3 direction;
};

struct PointLight {
    float3 color;
    float3 position;
    float distance;
};


struct SpotLight {
    float3 color;
    float3 position;
    float3 direction;
    float distance;
    float angleCos;
    float penumbraCos;
};

struct EnvMapLight {
    float3 diffuse;
    float mipMapLevel;
    float diffuseIntensity;
    float specularIntensity;
};
