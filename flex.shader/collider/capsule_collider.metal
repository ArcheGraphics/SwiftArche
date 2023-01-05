//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "../type_common.h"
#include "../function_constant.h"

struct ColliderQueryResult {
    float distance = numeric_limits<float>::max();
    float3 point;
    float3 normal;
    float3 velocity;
};

ColliderQueryResult getClosestPoint(constant CapsuleColliderShapeData* u_capsules, uint count, float3 position) {
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

kernel void capsuleCollider(device float3* u_position [[buffer(0)]],
                            device float3* u_velocity [[buffer(1)]],
                            device uint& u_counter [[buffer(2)]],
                            constant CapsuleColliderShapeData* u_capsules [[buffer(3)]],
                            constant ColliderData& u_collider [[buffer(4)]],
                            uint3 tpig [[ thread_position_in_grid ]],
                            uint3 gridSize [[ threads_per_grid ]]) {
    if (tpig.x < u_counter) {
        auto newVelocity = u_velocity[tpig.x];
        auto colliderPoint = getClosestPoint(u_capsules, u_collider.count, u_position[tpig.x]);
        if (colliderPoint.distance < u_collider.radius) {
            // Target point is the closest non-penetrating position from the
            // new position.
            float3 targetNormal = colliderPoint.normal;
            float3 targetPoint = colliderPoint.point + u_collider.radius * targetNormal;
            float3 colliderVelAtTargetPoint = colliderPoint.velocity;

            // Get new candidate relative velocity from the target point.
            float3 relativeVel = newVelocity - colliderVelAtTargetPoint;
            float normalDotRelativeVel = dot(targetNormal, relativeVel);
            float3 relativeVelN = normalDotRelativeVel * targetNormal;
            float3 relativeVelT = relativeVel - relativeVelN;
            
            // Check if the velocity is facing opposite direction of the surface
            // normal
            if (normalDotRelativeVel < 0.0) {
                // Apply restitution coefficient to the surface normal component of
                // the velocity
                float3 deltaRelativeVelN = (-u_collider.restitutionCoefficient - 1.0) * relativeVelN;
                relativeVelN *= -u_collider.restitutionCoefficient;
                
                // Apply friction to the tangential component of the velocity
                // From Bridson et al., Robust Treatment of Collisions, Contact and
                // Friction for Cloth Animation, 2002
                // http://graphics.stanford.edu/papers/cloth-sig02/cloth.pdf
                if (length_squared(relativeVelT) > 0.0) {
                    float frictionScale = max(1.0 - u_collider.frictionCoefficient * length(deltaRelativeVelN) / length(relativeVelT), 0.0);
                    relativeVelT *= frictionScale;
                }
                
                // Reassemble the components
                u_velocity[tpig.x] = relativeVelN + relativeVelT + colliderVelAtTargetPoint;
            }
            u_position[tpig.x] = targetPoint;
        }
    }
}
