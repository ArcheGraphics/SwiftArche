//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>
#include <metal_stdlib>
#include "mesh_types.h"
#include "type_common.h"
#include "arguments.h"

using namespace metal;

float pow2(float x);

float4x4 getJointMatrix(texture2d<float> joint_tex, float index, int u_jointCount);

float3 getBlendShapeVertexElement(int blendShapeIndex, int vertexElementIndex,
                                  uint3 u_blendShapeTextureInfo,
                                  texture2d_array<float> u_blendShapeTexture);

matrix_float2x2 inverse(matrix_float2x2 m);

matrix_float3x3 inverse(matrix_float3x3 m);

matrix_float4x4 inverse(matrix_float4x4 m);

