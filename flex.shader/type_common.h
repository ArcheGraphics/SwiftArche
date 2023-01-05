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

struct PointParticleEmitterData {
    vector_float3 origin;
    float speed;

    vector_float3 direction;
    float spreadAngleInRadians;
    
    uint32_t maxNumberOfParticles;
};

struct ColliderData {
    float radius;
    float restitutionCoefficient;
    float frictionCoefficient;
    uint32_t count;
};

struct RayMarchingData {
    vector_float3 color;
    uint32_t iteration;
    vector_float3 direction;
    float tol;
};

struct CapsuleColliderShapeData {
    vector_float3 a;
    float radius;
    
    vector_float3 b;
    vector_float3 linearVelocity;
    vector_float3 angularVelocity;
};

struct ForceData {
    vector_float3 gravity;
    float mass;
};

struct SSFData {
    float p_n;
    float p_f;
    float p_t;
    float p_r;
    
    float canvasWidth;
    float canvasHeight;
};

struct HashGridData {
    uint32_t resolutionX;
    uint32_t resolutionY;
    uint32_t resolutionZ;
    float gridSpacing;
};
