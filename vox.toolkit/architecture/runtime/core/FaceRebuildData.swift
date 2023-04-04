//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

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

    public static func Apply<T>(newFaces _: T,
                                mesh _: ProBuilderMesh,
                                vertices _: [Vertex]? = nil,
                                faces _: [Face]? = nil) where T: Sequence<FaceRebuildData> {}

    /// Shift face rebuild data to appropriate positions and update the vertex, face, and shared indexes arrays.
    public static func Apply<T>(newFaces _: T,
                                vertices _: [Vertex],
                                faces _: [Face],
                                sharedVertexLookup _: [Int: Int],
                                sharedTextureLookup _: [Int: Int]? = nil) where T: Sequence<FaceRebuildData> {}
}
