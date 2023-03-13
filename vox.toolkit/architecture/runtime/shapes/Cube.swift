//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

public class Cube: Shape {
    /// A set of 8 vertices forming the template for a cube mesh.
    static let k_CubeVertices: [Vector3] =
            [
                // bottom 4 verts
                Vector3(-0.5, -0.5, 0.5), // 0
                Vector3(0.5, -0.5, 0.5), // 1
                Vector3(0.5, -0.5, -0.5), // 2
                Vector3(-0.5, -0.5, -0.5), // 3

                // top 4 verts
                Vector3(-0.5, 0.5, 0.5), // 4
                Vector3(0.5, 0.5, 0.5), // 5
                Vector3(0.5, 0.5, -0.5), // 6
                Vector3(-0.5, 0.5, -0.5)        // 7
            ]

    /// A set of triangles forming a cube with reference to the k_CubeVertices array.
    static let k_CubeTriangles: [Int] = [
        0, 1, 4, 5, 1, 2, 5, 6, 2, 3, 6, 7, 3, 0, 7, 4, 4, 5, 7, 6, 3, 2, 0, 1
    ]

    public func CopyShape(_ shape: Shape) {

    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }
}
