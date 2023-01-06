//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "ray_marching.h"

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

//MARK: - Fragment
struct CapsuleSDF {
public:
    CapsuleSDF(constant CapsuleColliderShapeData* u_capsules,
               constant uint& u_count) :
    u_capsules(u_capsules), u_count(u_count) {}
    
    float operator()(Ray ray) {
        float dist = numeric_limits<float>::max();
        for (uint j = 0; j < u_count; j++) {
            CapsuleColliderShapeData data = u_capsules[j];
            dist = min(dist, sdCapsule(ray.origin, data.a, data.b, data.radius));
        }
        return dist;
    }
    
private:
    float sdCapsule(float3 p, float3 a, float3 b, float r) {
        float3 pa = p - a, ba = b - a;
        float h = clamp(dot(pa,ba) / dot(ba,ba), 0.0, 1.0);
        return length(pa - ba * h) - r;
    }
    
    constant CapsuleColliderShapeData* u_capsules;
    constant uint& u_count;
};

fragment fragmentOut fragment_rayMarching(VertexOut in [[stage_in]],
                                          constant CameraData& u_camera [[buffer(1)]],
                                          constant CapsuleColliderShapeData* u_capsules [[buffer(3)]],
                                          constant uint& u_count [[buffer(4)]],
                                          constant RayMarchingData& u_rayMarching [[buffer(5)]]) {
    CapsuleSDF sdf(u_capsules, u_count);
    RayMarching<CapsuleSDF> raymarching(u_camera, u_rayMarching, sdf);
    
    fragmentOut out = raymarching(Ray{u_camera.u_cameraPos, normalize(in.nearPoint - u_camera.u_cameraPos)});
    if (out.color.r < 0) {
        discard_fragment();
    }
    return out;
}
