//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "../vox.shader/type_common.h"
#import <simd/simd.h>

struct SDFData {
    vector_float3 SDFLower;
    vector_float3 SDFUpper;
};

struct VolumeParticleEmitterData {
    vector_float3 initialVelocity;
    float spacing;
    
    vector_float3 linearVelocity;
    uint32_t maxNumberOfParticles;
    
    vector_float3 angularVelocity;
    float jitter;
    
    vector_float3 lowerCorner;
};

struct SSFData {
    float p_n;
    float p_f;
    float p_t;
    float p_r;
    
    float canvasWidth;
    float canvasHeight;
};
