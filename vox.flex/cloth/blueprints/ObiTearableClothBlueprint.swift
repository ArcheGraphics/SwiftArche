//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiTearableClothBlueprint: ObiClothBlueprint {
    /// "Amount of memory preallocated to create extra particles and mesh data when tearing the cloth.
    /// 0 means no extra memory will be allocated, and the cloth will not be tearable. 1 means all cloth
    /// triangles will be fully tearable."
    public var tearCapacity: Float = 0.5

    private var pooledParticles = 0

    /// Per-particle tear resistance.
    public var tearResistance: [Float] = []
    /// constraintHalfEdgeMap[half-edge index] = distance constraint index, or -1 if there's no constraint.
    /// Each initial constraint is the lower-index of each pair of half-edges. When a half-edge is split during
    /// tearing, one of the two half-edges gets its constraint updated and the other gets a new constraint.
    public var distanceConstraintMap: [Vector2Int] = []
}
