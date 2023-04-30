//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstColliderCollisionConstraintsBatch: BurstConstraintsBatchImpl {
    public init(constraints: BurstColliderCollisionConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Collision
    }

    override public func Initialize(substepTime _: Float) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    /// Updates contact data (such as contact distance) at the beginning of each substep. This is
    /// necessary because contacts are generalted only once at the beginning of each step, not every substep.
    public struct UpdateContactsJob {
        public private(set) var prevPositions: [float4]
        public private(set) var prevOrientations: [quaternion]
        public private(set) var velocities: [float4]
        public private(set) var radii: [float4]
        public private(set) var invMasses: [Float]
        public private(set) var invInertiaTensors: [float4]

        public private(set) var particleMaterialIndices: [Int]
        public private(set) var collisionMaterials: [CollisionMaterial]

        // simplex arrays:
        public private(set) var simplices: [Int]
        public private(set) var simplexCounts: SimplexCounts

        public private(set) var shapes: [BurstColliderShape]
        public private(set) var transforms: [BurstAffineTransform]
        public private(set) var rigidbodies: [BurstRigidbody]
        public private(set) var rigidbodyLinearDeltas: [float4]
        public private(set) var rigidbodyAngularDeltas: [float4]

        public var contacts: [BurstContact]
        public private(set) var inertialFrame: BurstInertialFrame

        public func Execute(i _: Int) {}
    }

    public struct CollisionConstraintsBatchJob {
        public private(set) var prevPositions: [float4]
        public private(set) var orientations: [quaternion]
        public private(set) var prevOrientations: [quaternion]
        public private(set) var invMasses: [Float]
        public private(set) var radii: [float4]
        public private(set) var particleMaterialIndices: [Int]

        // simplex arrays:
        public private(set) var simplices: [Int]
        public private(set) var simplexCounts: SimplexCounts

        public private(set) var shapes: [BurstColliderShape]
        public private(set) var transforms: [BurstAffineTransform]
        public private(set) var collisionMaterials: [CollisionMaterial]
        public private(set) var rigidbodies: [BurstRigidbody]
        public var rigidbodyLinearDeltas: [float4]
        public var rigidbodyAngularDeltas: [float4]

        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public var contacts: [BurstContact]
        public private(set) var inertialFrame: BurstInertialFrame
        public private(set) var constraintParameters: Oni.ConstraintParameters
        public private(set) var solverParameters: Oni.SolverParameters
        public private(set) var stepTime: Float
        public private(set) var substepTime: Float
        public private(set) var substeps: Int

        public func Execute() {}

        private func CombineCollisionMaterials(entityA _: Int, entityB _: Int) -> CollisionMaterial {
            collisionMaterials[0]
        }
    }
}
