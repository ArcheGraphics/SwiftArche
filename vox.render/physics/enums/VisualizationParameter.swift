//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Debug visualization parameters.
public enum VisualizationParameter: UInt32 {
    // MARK: - RigidBody-related parameters

    /// Visualize the world axes.
    case WorldAxes = 1

    // MARK: - Body visualizations

    /// Visualize a bodies axes.
    case BodyAxes = 2
    /// Visualize a body's mass axes.
    case BodyMassAxes = 3
    /// Visualize the bodies linear velocity.
    case BodyLinVelocity = 4
    /// Visualize the bodies angular velocity.
    case BodyAngVelocity = 5

    // MARK: - Contact visualisations

    /// Visualize contact points. Will enable contact information.
    case ContactPoint = 6
    /// Visualize contact normals. Will enable contact information.
    case ContactNormal = 7
    /// Visualize contact errors. Will enable contact information.
    case ContactError = 8
    /// Visualize Contact forces. Will enable contact information.
    case ContactForce = 9
    /// Visualize actor axes.
    case ActorAxes = 10
    /// Visualize bounds (AABBs in world space)
    case CollisionAABBS = 11
    /// Shape visualization
    case CollisionShapes = 12
    /// Shape axis visualization
    case CollisionAxes = 13
    /// Compound visualization (compound AABBs in world space)
    case CollisionCompounds = 14
    /// Mesh & convex face normals
    case CollisionFaceNormal = 15
    /// Active edges for meshes
    case CollisionEdges = 16
    /// Static pruning structures
    case CollisionStatic = 17
    /// Dynamic pruning structures
    case CollisionDynamic = 18
    /// Joint local axes
    case JointLocalFrames = 19
    /// Joint limits
    case JointLimits = 20
    /// Visualize culling box
    case CullBox = 21
    /// MBP regions
    case MBPRegins = 22
}
