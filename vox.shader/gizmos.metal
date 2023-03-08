//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "function_constant.h"
#include "function_common.h"
#include "shader_common.h"

typedef struct {
    float3 POSITION [[attribute(Position)]];
    uchar4 COLOR_0 [[attribute(Color_0)]];
    float3 NORMAL [[attribute(Normal)]];
} GizmoVertexIn;

typedef struct {
    float4 position [[position]];
    float pointSize [[point_size]];
    uchar4 v_color;
    float3 normal;
    float3 v_pos;
} VertexOut;

vertex VertexOut vertex_point_gizmos(const GizmoVertexIn in [[stage_in]],
                                     constant CameraData &u_camera [[buffer(2)]],
                                     constant float &u_pointSize [[buffer(3)]]) {
    VertexOut out;
    
    float4 position = float4( in.POSITION, 1.0);
    out.position = u_camera.u_VPMat * position;
    out.pointSize = u_pointSize;
    out.v_color = in.COLOR_0;
    return out;
}

fragment float4 fragment_point_gizmos(VertexOut in [[stage_in]],
                                     float2 point [[point_coord]]) {
    float x = 2 * point.x - 1;
    float y = 2 * point.y - 1;
    float pho = x * x + y * y;
    if (pho > 1) discard_fragment();
    
    return float4(in.v_color.r / 255.0, in.v_color.g / 255.0, in.v_color.b /255.0, in.v_color.a / 255.0);
}

// MARK: -
vertex VertexOut vertex_line_gizmos(const GizmoVertexIn in [[stage_in]],
                                    constant CameraData &u_camera [[buffer(2)]]) {
    VertexOut out;
    
    float4 position = float4( in.POSITION, 1.0);
    out.position = u_camera.u_VPMat * position;
    out.v_color = in.COLOR_0;
    return out;
}

fragment float4 fragment_line_gizmos(VertexOut in [[stage_in]]) {
    return float4(in.v_color.r / 255.0, in.v_color.g / 255.0, in.v_color.b /255.0, in.v_color.a / 255.0);
}

// MARK: -
vertex VertexOut vertex_triangle_gizmos(const GizmoVertexIn in [[stage_in]],
                                        constant CameraData &u_camera [[buffer(3)]]) {
    VertexOut out;
    
    float4 position = float4( in.POSITION, 1.0);
    out.position = u_camera.u_VPMat * position;
    out.v_color = in.COLOR_0;
    out.normal = in.NORMAL;
    out.v_pos = in.POSITION;
    return out;
}

fragment float4 fragment_triangle_gizmos(VertexOut in [[stage_in]],
                                         constant CameraData &u_camera [[buffer(3)]]) {
    constexpr float shininess = 16;
    constexpr float3 lightDirection = float3(-1, -1, -1);

    float3 V = normalize(u_camera.u_cameraPos - in.v_pos);
    float3 halfDir = normalize( V - lightDirection );
    float s = pow( clamp( dot( in.normal, halfDir ), 0.0, 1.0 ), shininess );
    
    float d = max(dot(in.normal, -lightDirection), 0.0);
    float3 baseColor = float3(in.v_color.r / 255.0, in.v_color.g / 255.0, in.v_color.b /255.0);
    return float4(baseColor * (d + s) + float3(0.2, 0.2, 0.2), in.v_color.a /255.0);
}
