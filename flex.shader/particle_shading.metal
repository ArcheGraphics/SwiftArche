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
    uint v_id;
} VertexOut;

vertex VertexOut vertex_particle(const VertexIn vertexIn [[stage_in]],
                                 uint v_id [[vertex_id]],
                                 constant uint &hlIndex [[buffer(4)]],
                                 constant float &pointRadius [[buffer(5)]],
                                 constant float &pointScale [[buffer(6)]],
                                 constant CameraData &u_camera [[buffer(7)]]) {
    VertexOut out;
    
    float4 eyePos = u_camera.u_viewMat * float4(vertexIn.position, 1.0);
    float dist = length(float3(eyePos / eyePos.w));
    
    out.pointSize = (v_id == hlIndex ? 2 : 1) * pointRadius * (pointScale / dist);
    out.position = u_camera.u_projMat * eyePos;
    out.v_id = v_id;
    
    return out;
}

float4 hls_shading(uint iid, uint hlIndex, float2 point) {
    const uint hsl_loop = 360u;
    // float hsl_h = mod(iid, hsl_loop);
    // const float hsl_s = 1;
    float hsl_h = 220;
    float hsl_s = 1;
    float hsl_l = 0.5 + 0.4 * fmod(float(iid), hsl_loop) / hsl_loop;
    
    float hsl_hp = hsl_h / 60.0f;
    float hsl_c = hsl_s * (1 - abs(2 * hsl_l - 1));
    float hsl_x = hsl_c * (1 - abs(fmod(hsl_hp, 2) - 1));
    
    float3 rgb = float3(1, 1, 1);
    if (0 <= hsl_hp && hsl_hp <= 1)
        rgb = float3(hsl_c, hsl_x, 0);
    else if (1 <= hsl_hp && hsl_hp <= 2)
        rgb = float3(hsl_x, hsl_c, 0);
    else if (2 <= hsl_hp && hsl_hp <= 3)
        rgb = float3(0, hsl_c, hsl_x);
    else if (3 <= hsl_hp && hsl_hp <= 4)
        rgb = float3(0, hsl_x, hsl_c);
    else if (4 <= hsl_hp && hsl_hp <= 5)
        rgb = float3(hsl_x, 0, hsl_c);
    else if (5 <= hsl_hp && hsl_hp <= 6)
        rgb = float3(hsl_c, 0, hsl_x);
    rgb += hsl_l - 0.5 * hsl_c;
    
    float3 lightDir = normalize(float3(1, -1, 1));
    float x = 2 * point.x - 1;
    float y = 2 * point.y - 1;
    float pho = x * x + y * y;
    float z = sqrt(1 - pho);
    if (pho > 1) discard_fragment();
    
    float4 rgba = float4(dot(lightDir, float3(x, y, z)) * rgb, 1);
    float4 white = float4(dot(lightDir, float3(x, y, z)) * float3(1, 1, 1), 1) + 0.2;
    
    if (iid == hlIndex)
        return white;
    else
        return rgba;
}

float4 random_shading(uint iid, uint hlIndex, float2 point) {
    float3 lightDir = normalize(float3(1, -1, 1));
    float x = 2 * point.x - 1;
    float y = 2 * point.y - 1;
    float pho = x * x + y * y;
    float z = sqrt(1 - pho);
    if (pho > 1) discard_fragment();
    float r = iid % 16u / 16.f;
    float g = iid / 16u % 16u / 16.f;
    float b = iid / 16u % 16u / 16.f;
    float4 rgba = float4(dot(lightDir, float3(x, y, z)) * float3(r, g, b), 1);
    float4 white = float4(dot(lightDir, float3(x, y, z)) * float3(1, 1, 1), 1) + 0.2;
    if (iid == hlIndex)
        return white;
    else
        return rgba;
}


fragment float4 fragment_particle(VertexOut in [[stage_in]],
                                  constant uint &hlIndex [[buffer(4)]],
                                  float2 point [[point_coord]]) {
    return hls_shading(in.v_id, hlIndex, point);
}
