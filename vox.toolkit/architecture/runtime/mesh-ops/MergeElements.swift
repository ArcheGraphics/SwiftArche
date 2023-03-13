//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Methods for merging multiple faces of a <see cref="ProBuilderMesh"/> to a single face.
public class MergeElements {
    /// Merge each pair of faces to a single face. Indexes are combined,
    // but otherwise the properties of the first face in the pair take precedence.
    // Returns a list of the new faces created.
    public static func MergePairs(target: ProBuilderMesh, pairs: [(Face, Face)],
                                  collapseCoincidentVertices: Bool = true) -> [Face] {
        []
    }

    /// Merge a collection of faces to a single face. This function does not
    /// perform any sanity checks, it just merges faces. It's the caller's
    /// responsibility to make sure that the input is valid.
    /// In addition to merging faces this method also removes duplicate vertices
    /// created as a result of merging previously common vertices.
    public static func Merge<T: Sequence<Face>>(target: ProBuilderMesh, faces: T) -> Face {
        Face()
    }

    /// Condense co-incident vertex positions per-face. vertices must already be marked as shared in the sharedIndexes
    /// array to be considered. This method is really only useful after merging faces.
    internal static func CollapseCoincidentVertices<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) {
    }
}
