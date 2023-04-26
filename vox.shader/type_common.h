//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>
#import "config.h"

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

// MARK: - Light
struct PointLightData {
    /// Position in XYZ, radius squared in W.
    vector_float4 posSqrRadius;
    /// RGB color of light.
    vector_float3 color;
    /// Optional flags. May include `LIGHT_FOR_TRANSPARENT_FLAG`.
    uint flags;
};

// Point light information for culling.
struct PointLightCullingData {
    // Bounding sphere position in XYZ and radius of sphere in W.
    // Sign of radius:
    //  positive - transparency affecting light
    //  negative - light does not affect transparency
    vector_float4 posRadius;
};

struct SpotLightData {
    /// Position in XYZ and height of spot in W.
    vector_float4 posAndHeight;
    /// Bounding sphere for quick visibility test.
    vector_float4 boundingSphere;
    /// RGB color of light.
    vector_float4 colorAndInnerAngle;
    /// Direction in XYZ, cone angle in W.
    vector_float4 dirAndOuterAngle;
    /// View projection matrix to light space.
    matrix_float4x4  viewProjMatrix;
    /// Optional flags. May include `LIGHT_FOR_TRANSPARENT_FLAG`.
    uint flags;
};

// Spot light information for culling.
struct SpotLightCullingData {
    // Bounding sphere position in XYZ and radius of sphere in W.
    // Sign of radius:
    //  positive - transparency affecting light
    //  negative - light does not affect transparency
    vector_float4 posRadius;
    // View space position in XYZ and height of spot in W.
    vector_float4 posAndHeight;
    // View space direction in XYZ and cosine of outer angle in W.
    vector_float4 dirAndOuterAngle ;
};

struct DirectLightData {
    vector_float3 color;
    vector_float3 direction;
};

typedef struct CameraData {
    matrix_float4x4 u_viewMat;
    matrix_float4x4 u_projMat;
    matrix_float4x4 u_VPMat;
    
    matrix_float4x4 u_viewInvMat;
    matrix_float4x4 u_projInvMat;
    matrix_float4x4 u_invViewProjectionMatrix;

    vector_float3 u_cameraPos;
    
    // Frustum planes in world space.
    vector_float4 worldFrustumPlanes[6];

    // A float4 containing the lower right 2x2 z,w block of inv projection matrix (column major);
    //   viewZ = (X * projZ + Z) / (Y * projZ + W)
    vector_float4 invProjZ;

    // Same as invProjZ but the result is a Z from 0...1 instead of N...F;
    //  effectively linearizes Z for easy visualization/storage.
    vector_float4 invProjZNormalized;
} CameraData;

struct RendererData {
    matrix_float4x4 u_localMat;
    matrix_float4x4 u_modelMat;
    matrix_float4x4 u_normalMat;
};
