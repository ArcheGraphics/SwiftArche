//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

class UvUnwrapping {
    static var s_TempVector2 = Vector2.zero;
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

    internal static func Unwrap(mesh: ProBuilderMesh, face: Face, projection: Vector3 = Vector3()) {

    }

    /// Copy UVs from source to dest for the given mesh.
    /// - Parameters:
    ///   - mesh: ProbuilderMesh
    ///   - source: face to copy UVs from
    ///   - dest: face to copy UVs to
    internal static func CopyUVs(mesh: ProBuilderMesh, source: Face, dest: Face) {

    }

    internal static func ProjectTextureGroup(mesh: ProBuilderMesh, group: Int, unwrapSettings: AutoUnwrapSettings) {

    }

    static func ApplyUVSettings(for uvs: [Vector2], indexes: [Int], uvSettings: AutoUnwrapSettings) {

    }

    static func ScaleUVs(for uvs: [Vector2], indexes: [Int], scale: Vector2, bounds: Bounds2D) {

    }

    static func ApplyUVAnchor(for uvs: [Vector2], indexes: [Int], anchor: AutoUnwrapSettings.Anchor) {

    }

    // 2020/8/23 - scaled auto UV faces now have an offset applied to their projected coordinates so that they
    // remain static in UV space when the mesh geometry is modified
    internal static func UpgradeAutoUVScaleOffset(mesh: ProBuilderMesh) {

    }
}

// UvAutoManualConversion
extension UvUnwrapping {
    /// Sets the passed faces to use Auto or Manual UVs, and (if previously manual) splits any vertex connections.
    internal static func SetAutoUV(mesh: ProBuilderMesh, faces: [Face], auto: Bool) {
    }

    /// Reset the AutoUnwrapParameters of a set of faces to best match their current UV coordinates.
    /// - Remark:
    /// Auto UVs do not support distortion, so this conversion process cannot be loss-less. However as long as there
    /// is minimal skewing the results are usually very close.
    internal static func SetAutoAndAlignUnwrapParamsToUVs<T: Sequence<Face>>(mesh: ProBuilderMesh, facesToConvert: T) {
    }

    /// Returns the auto unwrap settings for a face. In cases where the face is auto unwrapped (manualUV = false),
    /// this returns an unmodified copy of the AutoUnwrapSettings. If the face is manually unwrapped, it returns
    /// the auto unwrap settings computed from GetUVTransform.
    internal static func GetAutoUnwrapSettings(mesh: ProBuilderMesh, face: Face) -> AutoUnwrapSettings {
        AutoUnwrapSettings()
    }

    /// Attempt to calculate the UV transform for a face. In cases where the face is auto unwrapped
    /// (manualUV = false), this returns the offset, rotation, and scale from <see cref="Face.uv"/>. If the face is
    /// manually unwrapped, a transform will be calculated by trying to match an unmodified planar projection to the
    /// current UVs. The results
    internal static func GetUVTransform(mesh: ProBuilderMesh, face: Face) -> UVTransform {
        UVTransform()
    }

    // messy hack to support cases where you want to iterate a collection of values with an optional collection of
    // indices. do not make public.
    static func GetIndex(collection: [Int], index: Int) -> Int {
        0
    }

    // indices arrays are optional - if null is passed the index will be 0, 1, 2... up to values array length.
    // this is done to avoid allocating a separate array just to pass linear indices
    internal static func CalculateDelta(src: [Vector2], srcIndices: [Int], dst: [Vector2], dstIndices: [Int]) -> UVTransform {
        UVTransform()
    }

    static func GetRotatedSize(points: [Vector2], indices: [Int], center: Vector2, rotation: Float) -> Vector2 {
        Vector2()
    }

}
