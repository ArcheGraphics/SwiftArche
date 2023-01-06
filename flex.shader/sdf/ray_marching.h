//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;
#include "../type_common.h"
#include "../function_constant.h"

struct fragmentOut {
    float4 color[[color(0)]];
    float depth[[depth(greater)]];
};

struct Ray {
    float3 origin;
    float3 direction;
};

template <typename Callback>
class RayMarching {
public:
    RayMarching(constant CameraData& u_camera,
                constant RayMarchingData& u_rayMarching,
                Callback callback) :
    u_camera(u_camera),
    u_rayMarching(u_rayMarching),
    callback(callback) {}
    
    fragmentOut operator()(Ray ray) {
        bool hit = false;
        for (uint i = 0; i < u_rayMarching.iteration; i++) {
            float dist = callback(ray);
            if (dist < u_rayMarching.tol) {
                hit = true;
                break;
            }
            ray.origin += ray.direction * dist;
        }
        
        fragmentOut out;
        if (!hit) {
            out.color.r = -1;
        } else {
            float3 n = getNormal(ray);
            float l = lighting(ray, n, u_rayMarching.direction);
            out.color = float4(u_rayMarching.color * l, 1.0);
            
            float4 ndcPos = u_camera.u_projMat * u_camera.u_viewMat * float4(ray.origin, 1.0);
            out.depth = ndcPos.z / ndcPos.w;
        }
        return out;
    }
    
private:
    float3 getNormal(Ray ray) {
        float2 eps = float2(0.001, 0.0);
        float3 n = float3(callback(Ray{ray.origin + eps.xyy, ray.direction}) -
                          callback(Ray{ray.origin - eps.xyy, ray.direction}),
                          callback(Ray{ray.origin + eps.yxy, ray.direction}) -
                          callback(Ray{ray.origin - eps.yxy, ray.direction}),
                          callback(Ray{ray.origin + eps.yyx, ray.direction}) -
                          callback(Ray{ray.origin - eps.yyx, ray.direction}));
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
    
    constant CameraData& u_camera;
    constant RayMarchingData& u_rayMarching;
    Callback callback;
};
