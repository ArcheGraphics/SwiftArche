//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"

typedef struct {
    float3 position [[attribute(0)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 viewPos;
} VertexOut;

vertex VertexOut vertex_ssf_depth_thick(const VertexIn vertexIn [[stage_in]],
                                        constant float &pointRadius [[buffer(5)]],
                                        constant float &canvasHeight [[buffer(6)]],
                                        constant CameraData &u_camera [[buffer(7)]]) {
    VertexOut out;
    
    out.viewPos = u_camera.u_viewMat * float4(vertexIn.position, 1.0);
    out.position = u_camera.u_projMat * out.viewPos;
    out.pointSize = pointRadius * canvasHeight * u_camera.u_projMat[1][1] / (-out.viewPos.z);
    
    
    return out;
}

struct fragmentOut {
    float4 thickness[[color(0)]];
    float depth[[depth(greater)]];
};

fragment fragmentOut fragment_ssf_depth_thick(VertexOut in [[stage_in]],
                                              constant float3 &lightDir [[buffer(5)]],
                                              constant float &pointRadius [[buffer(6)]],
                                              constant CameraData &u_camera [[buffer(7)]],
                                              float2 point [[point_coord]]) {
    float x = 2 * point.x - 1;
    float y = 2 * point.y - 1;
    float pho = x * x + y * y;
    float z = sqrt(1 - pho);
    if (pho > 1) {
        discard_fragment();
    }

    float4 nviewPos = float4(in.viewPos.xyz + float3(x, y, z) * pointRadius, 1);
    float4 nclipPos = u_camera.u_projMat * nviewPos;
    float nz_ndc = nclipPos.z / nclipPos.w;
    
    fragmentOut out;
    out.depth = 0.5 * (nz_ndc + 1);
    out.thickness = float4(2 * pointRadius * dot(float3(x, y, z), lightDir), 0, 0, 1);
    return out;
}
