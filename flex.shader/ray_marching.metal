//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"

typedef struct {
    float3 position [[attribute(Position)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float3 nearPoint;
} VertexOut;

vertex VertexOut vertex_rayMarching(const VertexIn in [[stage_in]],
                                    constant CameraData &u_camera [[buffer(7)]]) {
    VertexOut out;
    out.position = float4(in.position, 1.0);
    float4 nearPoint = u_camera.u_viewInvMat * u_camera.u_projInvMat * out.position;
    out.nearPoint = nearPoint.xyz / nearPoint.w;
    
    return out;
}

struct fragmentOut {
    float4 color[[color(0)]];
    float depth[[depth(greater)]];
};

struct Ray {
    float3 origin;
    float3 direction;
};

float sdCapsule(float3 p, float3 a, float3 b, float r) {
    float3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

float distToScene(Ray ray, constant CapsuleColliderShapeData* u_capsules, constant uint& u_count) {
    float dist = numeric_limits<float>::max();
    for (uint j = 0; j < u_count; j++) {
        CapsuleColliderShapeData data = u_capsules[j];
        dist = min(dist, sdCapsule(ray.origin, data.a, data.b, data.radius));
    }
    return dist;
}

float3 getNormal(Ray ray, constant CapsuleColliderShapeData* u_capsules, constant uint& u_count) {
    float2 eps = float2(0.001, 0.0);
    float3 n = float3(distToScene(Ray{ray.origin + eps.xyy, ray.direction}, u_capsules, u_count) -
                      distToScene(Ray{ray.origin - eps.xyy, ray.direction}, u_capsules, u_count),
                      distToScene(Ray{ray.origin + eps.yxy, ray.direction}, u_capsules, u_count) -
                      distToScene(Ray{ray.origin - eps.yxy, ray.direction}, u_capsules, u_count),
                      distToScene(Ray{ray.origin + eps.yyx, ray.direction}, u_capsules, u_count) -
                      distToScene(Ray{ray.origin - eps.yyx, ray.direction}, u_capsules, u_count));
    return normalize(n);
}

float lighting(Ray ray, float3 normal, float3 light) {
    // 1
    float3 lightRay = normalize(light - ray.origin);
    // 2
    float diffuse = max(0.0, dot(normal, lightRay));
    // 3
    float3 reflectedRay = reflect(ray.direction, normal);
    float specular = max(0.0, dot(reflectedRay, lightRay));
    // 4
    specular = pow(specular, 200.0);
    return diffuse + specular;
}

fragment fragmentOut fragment_rayMarching(VertexOut in [[stage_in]],
                                          constant CameraData& u_camera [[buffer(1)]],
                                          constant CapsuleColliderShapeData* u_capsules [[buffer(3)]],
                                          constant uint& u_count [[buffer(4)]],
                                          constant RayMarchingData& u_rayMarching [[buffer(5)]]) {
    Ray ray = Ray{u_camera.u_cameraPos, normalize(in.nearPoint - u_camera.u_cameraPos)};
    bool hit = false;
    for (uint i = 0; i < u_rayMarching.iteration; i++) {
        float dist = distToScene(ray, u_capsules, u_count);
        if (dist < u_rayMarching.tol) {
            hit = true;
            break;
        }
        ray.origin += ray.direction * dist;
    }
    
    fragmentOut out;
    if (!hit) {
        discard_fragment();
    } else {
        float3 n = getNormal(ray, u_capsules, u_count);
        float l = lighting(ray, n, u_rayMarching.direction);
        out.color = float4(u_rayMarching.color * l, 1.0);
        
        float4 ndcPos = u_camera.u_projMat * u_camera.u_viewMat * float4(ray.origin, 1.0);
        out.depth = ndcPos.z / ndcPos.w;
    }
    return out;
}
