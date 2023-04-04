//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// A collection of settings defining how mesh element picking behaves.
public struct PickerOptions {
    /// Should depth testing be performed when hit testing elements?
    /// Enable to select only visible elements, disable to select all elements regardless of visibility.
    public var depthTest: Bool

    /// Require elements to be completely encompassed by the rect selection (Complete) or only touched (Partial).
    /// - Remark:
    /// Does not apply to vertex picking.
    public var rectSelectMode: RectSelectMode

    static let k_Default = PickerOptions(depthTest: true, rectSelectMode: RectSelectMode.Partial)

    /// A set of options with default values.
    public static var Default: PickerOptions {
        k_Default
    }
}

extension PickerOptions: Hashable {}

internal protocol ISelectionPickerRenderer {
    func RenderLookupTexture(camera: Camera, shader: Material, tag: String, width: Int, height: Int) -> MTLTexture
}

/// Functions for picking elements in a view by rendering a picker texture and testing pixels.
enum SelectionPickerRenderer {
    static let k_FacePickerOcclusionTintUniform = "_Tint"
    static let k_Blackf = Color(0, 0, 0, 1)
    static let k_Whitef = Color(1, 1, 1, 1)
    static let k_PickerHashNone: UInt = 0x00
    static let k_PickerHashMin: UInt = 0x1
    static let k_PickerHashMax: UInt = 0x00FF_FFFF
    static let k_MinEdgePixelsForValidSelection: UInt = 1

    static var s_Initialized = false
    static var s_PickerRenderer: ISelectionPickerRenderer?

    static var renderTextureFormat: MTLPixelFormat {
        get {
            .invalid
        }
        set {}
    }

    static var textureFormat: MTLPixelFormat {
        return MTLPixelFormat.rgba32Float
    }

    static var s_RenderTextureFormat: MTLPixelFormat = .rgba32Float

    static var s_PreferredFormats: [MTLPixelFormat] = [
        MTLPixelFormat.rgba32Float,
        MTLPixelFormat.rgba16Float,
    ]

    /// Returns an appropriate implementation based on the graphic pipeline
    /// to generate the lookup texture.
    /// URP and Standard pipeline share the same picker implementation for now.
    static var pickerRenderer: ISelectionPickerRenderer? {
        s_PickerRenderer
    }

    /// Given a camera and selection rect (in screen space) return a Dictionary containing the number of faces touched by the rect.
    public static func PickFacesInRect(camera _: Camera,
                                       pickerRect _: Rect,
                                       selection _: [ProBuilderMesh],
                                       renderTextureWidth _: Int = -1,
                                       renderTextureHeight _: Int = -1) -> [ProBuilderMesh: Set<Face>]
    {
        [:]
    }

    /// Select vertex indexes contained within a rect.
    /// - Returns: A dictionary of pb_Object selected vertex indexes.
    public static func PickVerticesInRect(camera _: Camera,
                                          pickerRect _: Rect,
                                          selection _: [ProBuilderMesh],
                                          doDepthTest _: Bool,
                                          renderTextureWidth _: Int = -1,
                                          renderTextureHeight _: Int = -1) -> [ProBuilderMesh: Set<Int>]
    {
        [:]
    }

    /// Select edges touching a rect.
    /// - Returns: A dictionary of pb_Object and selected edges.
    public static func PickEdgesInRect(camera _: Camera,
                                       pickerRect _: Rect,
                                       selection _: [ProBuilderMesh],
                                       doDepthTest _: Bool,
                                       renderTextureWidth _: Int = -1,
                                       renderTextureHeight _: Int = -1) -> [ProBuilderMesh: Set<Edge>]
    {
        [:]
    }

    /// Render the pb_Object selection with the special selection picker shader and return a texture and color -> {object, face} dictionary.
    internal static func RenderSelectionPickerTexture(camera _: Camera,
                                                      selection _: [ProBuilderMesh],
                                                      map _: inout [UInt: (ProBuilderMesh, Face)],
                                                      width _: Int = -1,
                                                      height _: Int = -1) -> MTLTexture?
    {
        nil
    }

    /// Render the pb_Object selection with the special selection picker shader and return a texture and color -> {object, sharedIndex} dictionary.
    internal static func RenderSelectionPickerTexture(camera _: Camera,
                                                      selection _: [ProBuilderMesh],
                                                      doDepthTest _: Bool,
                                                      map _: inout [UInt: (ProBuilderMesh, Int)],
                                                      width _: Int = -1,
                                                      height _: Int = -1) -> MTLTexture?
    {
        nil
    }

    /// Render the pb_Object selection with the special selection picker shader and return a texture and color -> {object, edge} dictionary.
    internal static func RenderSelectionPickerTexture(camera _: Camera,
                                                      selection _: [ProBuilderMesh],
                                                      doDepthTest _: Bool,
                                                      map _: inout [UInt: (ProBuilderMesh, Edge)],
                                                      width _: Int = -1,
                                                      height _: Int = -1) -> MTLTexture?
    {
        nil
    }

    static func GenerateFacePickingObjects(selection _: [ProBuilderMesh],
                                           map _: inout [UInt: (ProBuilderMesh, Face)]) -> [Entity]
    {
        []
    }

    static func GenerateVertexPickingObjects(selection _: [ProBuilderMesh],
                                             doDepthTest _: Bool,
                                             map _: inout [UInt: (ProBuilderMesh, Int)],
                                             depthObjects _: inout [Entity],
                                             pickerObjects _: inout [Entity]) {}

    static func GenerateEdgePickingObjects(selection _: [ProBuilderMesh],
                                           doDepthTest _: Bool,
                                           map _: inout [uint: (ProBuilderMesh, Edge)],
                                           depthObjects _: inout [Entity],
                                           pickerObjects _: inout [Entity]) {}

    static func BuildVertexMesh(pb _: ProBuilderMesh, map _: [UInt: (ProBuilderMesh, Int)], index _: inout UInt) -> Mesh {
        Mesh()
    }

    static func BuildEdgeMesh(pb _: ProBuilderMesh, map _: [UInt: (ProBuilderMesh, Edge)], index _: inout UInt) -> Mesh {
        Mesh()
    }

    /// Decode Color32.RGB values to a 32 bit unsigned int, using the RGB as the little bytes. Discards the hi byte (alpha)
    public static func DecodeRGBA(color: Color32) -> UInt {
        let r = UInt(color.r)
        let g = UInt(color.g)
        let b = UInt(color.b)

        // IsLittleEndian
        return r << 16 | g << 8 | b
    }

    /// Encode the low 24 bits of a UInt32 to RGB of Color32, using 255 for A.
    public static func EncodeRGBA(hash: UInt) -> Color32 {
        // IsLittleEndian
        Color32(
            r: UInt8(hash >> 16 & 0xFF),
            g: UInt8(hash >> 8 & 0xFF),
            b: UInt8(hash & 0xFF),
            a: UInt8(255)
        )
    }
}
