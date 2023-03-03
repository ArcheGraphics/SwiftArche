//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class Sphere: Shape {
    static let k_IcosphereVertices: [Vector3] = [
        Vector3(-1, Math.phi, 0),
        Vector3(1, Math.phi, 0),
        Vector3(-1, -Math.phi, 0),
        Vector3(1, -Math.phi, 0),

        Vector3(0, -1, Math.phi),
        Vector3(0, 1, Math.phi),
        Vector3(0, -1, -Math.phi),
        Vector3(0, 1, -Math.phi),

        Vector3(Math.phi, 0, -1),
        Vector3(Math.phi, 0, 1),
        Vector3(-Math.phi, 0, -1),
        Vector3(-Math.phi, 0, 1)
    ]

    static let k_IcosphereTriangles: [Int] = [
        0, 11, 5,
        0, 5, 1,
        0, 1, 7,
        0, 7, 10,
        0, 10, 11,

        1, 5, 9,
        5, 11, 4,
        11, 10, 2,
        10, 7, 6,
        7, 1, 8,

        3, 9, 4,
        3, 4, 2,
        3, 2, 6,
        3, 6, 8,
        3, 8, 9,

        4, 9, 5,
        2, 4, 11,
        6, 2, 10,
        8, 6, 7,
        9, 8, 1
    ]

    var m_Subdivisions = 3

    var m_BottomMostVertexIndex = 0

    var m_Smooth: Bool = true

    public func CopyShape(_ shape: Shape) {

    }

    public func UpdateBounds(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion, bounds: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }

    // Subdivides a set of vertices (wound as individual triangles) on an icosphere.
    //
    //   /\          /\
    //  /  \  ->    /--\
    // /____\      /_\/_\
    //
    static func SubdivideIcosahedron(vertices: [Vector3], radius: Float) -> [Vector3] {
        []
    }
}
