//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Information required to append a face to a pb_Object.
final class FaceRebuildData {
    // new pb_Face
    public lazy var face: Face? = nil
    // new vertices (all vertices required to rebuild, not just new)
    public lazy var vertices: [Vertex] = []
    // shared indexes pointers (must match vertices length)
    public lazy var sharedIndexes: [Int] = []
    // shared UV indexes pointers (must match vertices length)
    public lazy var sharedIndexesUV: [Int] = []
    // The offset applied to this face via Apply() call.
    private lazy var _appliedOffset: Int = 0

    /// If this face has been applied to a pb_Object via Apply() this returns the index offset applied.
    public func Offset() -> Int {
        0
    }

    public static func Apply<T>(newFaces: T,
                                mesh: ProBuilderMesh,
                                vertices: [Vertex]? = nil,
                                faces: [Face]? = nil) where T: Sequence<FaceRebuildData> {
    }

    /// Shift face rebuild data to appropriate positions and update the vertex, face, and shared indexes arrays.
    public static func Apply<T>(newFaces: T,
                                vertices: [Vertex],
                                faces: [Face],
                                sharedVertexLookup: [Int: Int],
                                sharedTextureLookup: [Int: Int]? = nil) where T: Sequence<FaceRebuildData> {
    }
}
