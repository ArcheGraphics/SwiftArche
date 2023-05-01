//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiClothBlueprintBase: ObiMeshBasedActorBlueprint {
    /// Topology generated from the input mesh.
    public var topology: HalfEdgeMesh!

    /// Indices of deformable triangles (3 per triangle)
    public lazy var deformableTriangles: [Int] = []
    public lazy var restNormals: [Vector3] = []
    /// How much mesh surface area each particle represents.
    public lazy var areaContribution: [Float] = []

    public static let DEFAULT_PARTICLE_MASS: Float = 0.1

    var colorizer = GraphColoring()
}
