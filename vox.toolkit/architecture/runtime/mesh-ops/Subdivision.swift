//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Subdivide a ProBuilder mesh.
class Subdivision {
    /// Subdivide all faces on the mesh.
    /// - Remark:
    /// More accurately, this inserts a vertex at the center of each face and connects each edge at it's center.
    public static func Subdivide(pb: ProBuilderMesh) -> ActionResult {
        ActionResult.Success
    }

    /// Subdivide a mesh, optionally restricting to the specified faces.
    /// - Parameters:
    ///   - pb: pb
    ///   - faces: The faces to be affected by subdivision.
    /// - Returns: The faces created as a result of the subdivision.
    public static func Subdivide(pb: ProBuilderMesh, faces: [Face]) -> [Face] {
        []
    }
}
