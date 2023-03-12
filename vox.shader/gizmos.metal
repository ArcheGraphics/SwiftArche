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

float4 GetAmbient(float3 _world_normal) {
    float3 normal = normalize(_world_normal);
    float3 alpha = (normal + 1.) * .5;
    float2 bt = mix(float2(.3, .7), float2(.4, .8), alpha.xz);
    float3 ambient = mix(float3(bt.x, .3, bt.x), float3(bt.y, .8, bt.y), alpha.y);
    return float4(ambient, 1.);
}

fragment float4 fragment_triangle_gizmos(VertexOut in [[stage_in]],
                                         constant CameraData &u_camera [[buffer(3)]]) {
    float4 ambient = GetAmbient(in.normal);
    float4 baseColor = float4(in.v_color.r / 255.0, in.v_color.g / 255.0, in.v_color.b /255.0, in.v_color.a /255.0);
    return baseColor * ambient;
}
