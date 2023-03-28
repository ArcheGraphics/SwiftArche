//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>

#define NUM_CASCADES (3)

#define GAME_TIME 1.1f

// Matrices that are stored and generated internally within the camera object
typedef struct
{
    simd_float4x4      viewMatrix;
    simd_float4x4      projectionMatrix;
    simd_float4x4      viewProjectionMatrix;
    simd_float4x4      invOrientationProjectionMatrix;
    simd_float4x4      invViewProjectionMatrix;
    simd_float4x4      invProjectionMatrix;
    simd_float4x4      invViewMatrix;
    simd_float4        frustumPlanes[6];
} AAPLCameraUniforms;

struct AAPLUniforms
{
    AAPLCameraUniforms  cameraUniforms;
    AAPLCameraUniforms  shadowCameraUniforms[3];

    // Mouse state: x,y = position in pixels; z = buttons
    simd_float3        mouseState;
    simd_float2        invScreenSize;
    float               projectionYScale;
    float               brushSize;

    float               ambientOcclusionContrast;
    float               ambientOcclusionScale;
    float               ambientLightScale;
#if !USE_CONST_GAME_TIME
    float               gameTime;
#endif
    float               frameTime;  // TODO. this doesn't appear to be initialized until UpdateCpuUniforms. OK?
};

struct AAPLDebugVertex
{
    simd_float4        position;
    simd_float4        color;
};

// Describes our standardized OBJ format geometry vertex format
struct AAPLObjVertex
{
    simd_float3        position;
    simd_float3        normal;
    simd_float3        color;
};
