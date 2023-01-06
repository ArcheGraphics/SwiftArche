//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "rigid_body_collider.h"

class CapsuleColliderShape {
public:
    CapsuleColliderShape(constant CapsuleColliderShapeData* u_capsules, uint count):
    u_capsules(u_capsules), count(count) {}
    
    ColliderQueryResult operator()(float3 position) {
        ColliderQueryResult result;
        float3 minDirection;
        uint minIndex;
        
        for (uint i = 0; i < count; i++) {
            CapsuleColliderShapeData data = u_capsules[i];
            float3 pa = position - data.a, ba = data.b - data.a;
            float h = clamp(dot(pa,ba) / dot(ba,ba), 0.0, 1.0);
            float3 direction = pa - ba * h;
            float distance = length(direction) - data.radius;
            if (result.distance > distance) {
                result.distance = distance;
                minIndex = i;
                minDirection = direction;
            }
        }
        
        result.normal = normalize(minDirection);
        result.point = position - result.normal * result.distance;
        
        CapsuleColliderShapeData data = u_capsules[minIndex];
        float3 r = position - (data.a + data.b) * 0.5;
        result.velocity = data.linearVelocity + cross(data.angularVelocity, r);
        
        return result;
    }
    
private:
    constant CapsuleColliderShapeData* u_capsules;
    uint count;
};

kernel void capsuleCollider(device float3* u_position [[buffer(0)]],
                            device float3* u_velocity [[buffer(1)]],
                            device uint& u_counter [[buffer(2)]],
                            constant CapsuleColliderShapeData* u_capsules [[buffer(3)]],
                            constant ColliderData& u_collider [[buffer(4)]],
                            uint3 tpig [[ thread_position_in_grid ]],
                            uint3 gridSize [[ threads_per_grid ]]) {
    if (tpig.x < u_counter) {
        CapsuleColliderShape colliderShapeFunctor(u_capsules, u_collider.count);
        RigidBodyCollider<CapsuleColliderShape> collider(u_position, u_velocity, u_collider, colliderShapeFunctor);
        collider(tpig.x);
    }
}
