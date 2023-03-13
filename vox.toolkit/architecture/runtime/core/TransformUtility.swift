//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Helper functions for working with transforms.
public class TransformUtility {
    static var s_ChildStack: Dictionary<Transform, [Transform]> = [:]

    /// Unparent all children from a transform, saving them for later re-parenting (see ReparentChildren).
    internal static func UnparentChildren(t: Transform) {
    }

    /// Re-parent all children to a transform.  Must have called UnparentChildren prior.
    internal static func ReparentChildren(t: Transform) {
    }

    /// Transform a vertex into world space.
    /// - Parameters:
    ///   - transform: The transform to apply.
    ///   - vertex: A model space vertex.
    /// - Returns: A new vertex in world coordinate space.
    public static func TransformVertex(transform: Transform, vertex: Vertex) -> Vertex {
        Vertex()
    }

    /// Transform a vertex from world space to local space.
    /// - Parameters:
    ///   - transform: The transform to apply.
    ///   - vertex: A world space vertex.
    /// - Returns: A new vertex in transform coordinate space.
    public static func InverseTransformVertex(transform: Transform, vertex: Vertex) -> Vertex {
        Vertex()
    }
}
