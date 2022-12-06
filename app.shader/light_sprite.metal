//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
#include "function_constant.h"
#include "type_common.h"

constant array<float2, 4> pos = {
    float2(-1.0, 1.0),
    float2(-1.0, -1.0),
    float2(1.0, 1.0),
    float2(1.0, -1.0)
};

struct VertexOutput {
    float4 position [[position]];
    float2 localPos;
    float3 color;
};

vertex VertexOutput vertex_point_light_sprite(constant matrix_float4x4 &u_viewMat [[buffer(3)]],
                                              constant matrix_float4x4 &u_projMat [[buffer(4)]],
                                              device PointLightData *u_pointLight [[buffer(11), function_constant(hasPointLight)]],
                                              uint instanceIndex [[ instance_id ]],
                                              uint vertexIndex [[ vertex_id ]]) {
    VertexOutput output;
    
    output.localPos = pos[vertexIndex];
    output.color = u_pointLight[instanceIndex].color;
    float3 worldPos = float3(output.localPos, 0.0) * u_pointLight[instanceIndex].distance * 0.025;
    
    // Generate a billboarded model view matrix
    matrix_float4x4 bbModelViewMatrix = matrix_float4x4(1.0);
    bbModelViewMatrix[3] = float4(u_pointLight[instanceIndex].position, 1.0);
    bbModelViewMatrix = u_viewMat * bbModelViewMatrix;
    bbModelViewMatrix[0][0] = 1.0;
    bbModelViewMatrix[0][1] = 0.0;
    bbModelViewMatrix[0][2] = 0.0;
    
    bbModelViewMatrix[1][0] = 0.0;
    bbModelViewMatrix[1][1] = 1.0;
    bbModelViewMatrix[1][2] = 0.0;
    
    bbModelViewMatrix[2][0] = 0.0;
    bbModelViewMatrix[2][1] = 0.0;
    bbModelViewMatrix[2][2] = 1.0;
    
    output.position = u_projMat * bbModelViewMatrix * float4(worldPos, 1.0);
    return output;
}

vertex VertexOutput vertex_spot_light_sprite(constant matrix_float4x4 &u_viewMat [[buffer(3)]],
                                             constant matrix_float4x4 &u_projMat [[buffer(4)]],
                                             device SpotLightData *u_spotLight [[buffer(11), function_constant(hasSpotLight)]],
                                             uint instanceIndex [[ instance_id ]],
                                             uint vertexIndex [[ vertex_id ]]) {
    VertexOutput output;
    
    output.localPos = pos[vertexIndex];
    output.color = u_spotLight[instanceIndex].color;
    float3 worldPos = float3(output.localPos, 0.0) * u_spotLight[instanceIndex].distance * 0.025;
    
    // Generate a billboarded model view matrix
    matrix_float4x4 bbModelViewMatrix;
    bbModelViewMatrix[3] = float4(u_spotLight[instanceIndex].position, 1.0);
    bbModelViewMatrix = u_viewMat * bbModelViewMatrix;
    bbModelViewMatrix[0][0] = 1.0;
    bbModelViewMatrix[0][1] = 0.0;
    bbModelViewMatrix[0][2] = 0.0;
    
    bbModelViewMatrix[1][0] = 0.0;
    bbModelViewMatrix[1][1] = 1.0;
    bbModelViewMatrix[1][2] = 0.0;
    
    bbModelViewMatrix[2][0] = 0.0;
    bbModelViewMatrix[2][1] = 0.0;
    bbModelViewMatrix[2][2] = 1.0;
    
    output.position = u_projMat * bbModelViewMatrix * float4(worldPos, 1.0);
    return output;
}

fragment float4 fragment_light_sprite(VertexOutput input [[ stage_in ]]) {
    float distToCenter = length(input.localPos);
    float fade = (1.0 - distToCenter) * (1.0 / (distToCenter * distToCenter));
    return float4(input.color * fade, fade);
}

