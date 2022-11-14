//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "type_common.h"

typedef struct {
    float3 POSITION [[attribute(Position)]];
    float3 NORMAL [[attribute(Normal), function_constant(notOmitNormalAndHasNormal)]];
    float4 COLOR_0 [[attribute(Color_0), function_constant(hasVertexColor)]];
    float4 WEIGHTS_0 [[attribute(Weights_0), function_constant(hasSkin)]];
    float4 JOINTS_0 [[attribute(Joints_0), function_constant(hasSkin)]];
    float4 TANGENT [[attribute(Tangent), function_constant(notOmitNormalAndHasTangent)]];
    float2 TEXCOORD_0 [[attribute(UV_0), function_constant(hasUV)]];
} VertexIn;
