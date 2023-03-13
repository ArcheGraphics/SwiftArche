//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Defines associations between vertex positions that are coincident. The indexes stored in this collection correspond to the ProBuilderMesh.positions array.
/// Coincident vertices are vertices that despite sharing the same coordinate position, are separate entries in the vertex array.
public final class SharedVertex {
    /// An array of vertex indexes that are coincident.
    var m_Vertices: [Int] = []

    internal var arrayInternal: [Int] {
        get {
            m_Vertices;
        }
    }

    /// Create a new SharedVertex from an int array.
    /// - Parameter indexes: The array to copy.
    public init<T: Sequence<Int>>(indexes: T) {
        m_Vertices = [Int](indexes)
    }

    /// Copy constructor.
    /// - Parameter sharedVertex: The array to copy.
    public init(_ sharedVertex: SharedVertex) {
        m_Vertices = sharedVertex.m_Vertices
    }
}
