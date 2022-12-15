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
    uint32_t   MaxTraceSteps;
    vector_float3 SDFUpper;
    float AbsThreshold;
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
