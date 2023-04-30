//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstContact: IConstraint {
    /// point A, expressed as simplex barycentric coords for simplices, as a solver-space position for colliders./
    public var pointA: float4
    /// point B, expressed as simplex barycentric coords for simplices, as a solver-space position for colliders./
    public var pointB: float4

    public var normal: float4
    public var tangent: float4
    public var bitangent: float4

    public var distance: Float

    var normalLambda: Float
    var tangentLambda: Float
    var bitangentLambda: Float
    var stickLambda: Float
    var rollingFrictionImpulse: Float

    public var bodyA: Int
    public var bodyB: Int

    public var normalInvMassA: Float
    public var tangentInvMassA: Float
    public var bitangentInvMassA: Float

    public var normalInvMassB: Float
    public var tangentInvMassB: Float
    public var bitangentInvMassB: Float

    public func GetParticleCount() -> Int { return 2 }
    public func GetParticle(at index: Int) -> Int { return index == 0 ? bodyA : bodyB }

    public var TotalNormalInvMass: Float { return normalInvMassA + normalInvMassB }

    public var TotalTangentInvMass: Float { return tangentInvMassA + tangentInvMassB }

    public var TotalBitangentInvMass: Float { return bitangentInvMassA + bitangentInvMassB }

    public func CalculateBasis(relativeVelocity _: float4) {}

    public func CalculateContactMassesA(invMass _: Float,
                                        inverseInertiaTensor _: float4,
                                        position _: float4,
                                        orientation _: quaternion,
                                        contactPoint _: float4,
                                        rollingContacts _: Bool) {}

    public func CalculateContactMassesB(invMass _: Float,
                                        inverseInertiaTensor _: float4,
                                        position _: float4,
                                        orientation _: quaternion,
                                        contactPoint _: float4,
                                        rollingContacts _: Bool) {}

    public func CalculateContactMassesB(rigidbody _: BurstRigidbody, solver2World _: BurstAffineTransform) {}

    public func SolveAdhesion(posA _: float4, posB _: float4, stickDistance _: Float, stickiness _: Float, dt _: Float) -> Float {
        0
    }

    public func SolvePenetration(posA _: float4, posB _: float4, maxDepenetrationDelta _: Float) -> Float {
        0
    }

    public func SolveFriction(relativeVelocity _: float4, staticFriction _: Float, dynamicFriction _: Float, dt _: Float) -> float2 {
        float2()
    }

    public func SolveRollingFriction(angularVelocityA _: float4,
                                     angularVelocityB _: float4,
                                     rollingFriction _: Float,
                                     invMassA _: Float,
                                     invMassB _: Float,
                                     rolling_axis _: float4) -> Float
    {
        0
    }
}
