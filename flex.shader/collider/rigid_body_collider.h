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

struct ColliderQueryResult {
    float distance = numeric_limits<float>::max();
    float3 point;
    float3 normal;
    float3 velocity;
};

template <typename Callback>
class RigidBodyCollider {
public:
    RigidBodyCollider(device float3* u_position,
                      device float3* u_velocity,
                      constant ColliderData& u_collider, Callback cb) :
    u_position(u_position),
    u_velocity(u_velocity),
    u_collider(u_collider),
    callback(cb) {}
    
    template <typename Index>
    void operator()(Index idx) {
        auto newVelocity = u_velocity[idx];
        ColliderQueryResult colliderPoint = callback(u_position[idx]);
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
                u_velocity[idx] = relativeVelN + relativeVelT + colliderVelAtTargetPoint;
            }
            u_position[idx] = targetPoint;
        }
    }
    
private:
    device float3* u_position;
    device float3* u_velocity;
    constant ColliderData& u_collider;
    Callback callback;
};
