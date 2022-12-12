//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "physics_helpers.h"

float2 ComputeDragForce(float dragCoefficient, float radius, float2 velocity) {
    // Stoke's drag force assuming our Reynolds number is very low.
    // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
    return -6.0 * M_PI_F * dragCoefficient * radius * velocity;
}

float3 ComputeDragForce(float dragCoefficient, float radius, float3 velocity) {
    // Stoke's drag force assuming our Reynolds number is very low.
    // http://en.wikipedia.org/wiki/Drag_(physics)#Very_low_Reynolds_numbers:_Stokes.27_drag
    return -6.0 * M_PI_F * dragCoefficient * radius * velocity;
}
