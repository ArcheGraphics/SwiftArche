//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "samplers.h"

float3 uniformSampleCone(float u1, float u2, float3 axis, float angle) {
    float cosAngle_2 = cos(angle / 2);
    float y = 1 - (1 - cosAngle_2) * u1;
    float r = sqrt(max(0.0, 1 - y * y));
    float phi = M_PI_F * 2 * u2;
    float x = r * cos(phi);
    float z = r * sin(phi);
    
    float3 a = (abs(axis.y) > 0 || abs(axis.z) > 0) ? float3(1, 0, 0) : float3(0, 1, 0);
    a = cross(a, axis);
    a = normalize(a);
    float3 b = cross(axis, a);
    return a * x + axis * y + b * z;
}

float3 uniformSampleSphere(float u1, float u2) {
    float y = 1 - 2 * u1;
    float r = sqrt(max(0.0, 1 - y * y));
    float phi = M_PI_F * 2 * u2;
    float x = r * cos(phi);
    float z = r * sin(phi);
    return float3(x, y, z);
}
