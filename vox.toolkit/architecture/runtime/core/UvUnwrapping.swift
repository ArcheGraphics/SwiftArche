//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class UvUnwrapping {
    static var s_TempVector2 = Vector2.zero
    static let s_IndexBuffer = [Int](repeating: 0, count: 64)

    internal struct UVTransform: CustomStringConvertible {
        public var translation = Vector2()
        public var rotation = 0
        public var scale = Vector2()

        var description: String {
            ""
        }
    }

    static var s_UVTransformProjectionBuffer = [Vector2](repeating: Vector2(), count: 8)

    internal static func Unwrap(mesh _: ProBuilderMesh, face _: Face, projection _: Vector3 = Vector3()) {}

    /// Copy UVs from source to dest for the given mesh.
    /// - Parameters:
    ///   - mesh: ProbuilderMesh
    ///   - source: face to copy UVs from
    ///   - dest: face to copy UVs to
    internal static func CopyUVs(mesh _: ProBuilderMesh, source _: Face, dest _: Face) {}

    internal static func ProjectTextureGroup(mesh _: ProBuilderMesh, group _: Int, unwrapSettings _: AutoUnwrapSettings) {}

    static func ApplyUVSettings(for _: [Vector2], indexes _: [Int], uvSettings _: AutoUnwrapSettings) {}

    static func ScaleUVs(for _: [Vector2], indexes _: [Int], scale _: Vector2, bounds _: Bounds2D) {}

    static func ApplyUVAnchor(for _: [Vector2], indexes _: [Int], anchor _: AutoUnwrapSettings.Anchor) {}

    // 2020/8/23 - scaled auto UV faces now have an offset applied to their projected coordinates so that they
    // remain static in UV space when the mesh geometry is modified
    internal static func UpgradeAutoUVScaleOffset(mesh _: ProBuilderMesh) {}
}

// UvAutoManualConversion
extension UvUnwrapping {
    /// Sets the passed faces to use Auto or Manual UVs, and (if previously manual) splits any vertex connections.
    static func SetAutoUV(mesh _: ProBuilderMesh, faces _: [Face], auto _: Bool) {}

    /// Reset the AutoUnwrapParameters of a set of faces to best match their current UV coordinates.
    /// - Remark:
    /// Auto UVs do not support distortion, so this conversion process cannot be loss-less. However as long as there
    /// is minimal skewing the results are usually very close.
    static func SetAutoAndAlignUnwrapParamsToUVs<T: Sequence<Face>>(mesh _: ProBuilderMesh, facesToConvert _: T) {}

    /// Returns the auto unwrap settings for a face. In cases where the face is auto unwrapped (manualUV = false),
    /// this returns an unmodified copy of the AutoUnwrapSettings. If the face is manually unwrapped, it returns
    /// the auto unwrap settings computed from GetUVTransform.
    static func GetAutoUnwrapSettings(mesh _: ProBuilderMesh, face _: Face) -> AutoUnwrapSettings {
        AutoUnwrapSettings()
    }

    /// Attempt to calculate the UV transform for a face. In cases where the face is auto unwrapped
    /// (manualUV = false), this returns the offset, rotation, and scale from <see cref="Face.uv"/>. If the face is
    /// manually unwrapped, a transform will be calculated by trying to match an unmodified planar projection to the
    /// current UVs. The results
    static func GetUVTransform(mesh _: ProBuilderMesh, face _: Face) -> UVTransform {
        UVTransform()
    }

    // messy hack to support cases where you want to iterate a collection of values with an optional collection of
    // indices. do not make public.
    static func GetIndex(collection _: [Int], index _: Int) -> Int {
        0
    }

    // indices arrays are optional - if null is passed the index will be 0, 1, 2... up to values array length.
    // this is done to avoid allocating a separate array just to pass linear indices
    static func CalculateDelta(src _: [Vector2], srcIndices _: [Int], dst _: [Vector2], dstIndices _: [Int]) -> UVTransform {
        UVTransform()
    }

    static func GetRotatedSize(points _: [Vector2], indices _: [Int], center _: Vector2, rotation _: Float) -> Vector2 {
        Vector2()
    }
}
