//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Defines what objects are selectable for the scene tool.
public struct SelectMode: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// No selection mode defined.
    public static let None = SelectMode(rawValue: 0 << 0)
    /// Objects are selectable.
    public static let Object = SelectMode(rawValue: 1 << 0)
    /// Vertices are selectable.
    public static let Vertex = SelectMode(rawValue: 1 << 1)
    /// Edges are selectable.
    public static let Edge = SelectMode(rawValue: 1 << 2)
    /// Faces are selectable.
    public static let Face = SelectMode(rawValue: 1 << 3)
    /// Texture coordinates are selectable.
    public static let TextureFace = SelectMode(rawValue: 1 << 4)
    /// Texture coordinates are selectable.
    public static let TextureEdge = SelectMode(rawValue: 1 << 5)
    /// Texture coordinates are selectable.
    public static let TextureVertex = SelectMode(rawValue: 1 << 6)
    /// Other input tool (Poly Shape editor, Bezier editor, etc)
    public static let InputTool = SelectMode(rawValue: 1 << 7)
    /// Match any value.
    public static let AnyMode = SelectMode(rawValue: 0xFFFF)
}

/// Element selection mode.
enum ComponentMode: UInt8 {
    /// Vertices are selectable.
    case Vertex = 0x0
    /// Edges are selectable.
    case Edge = 0x1
    /// Faces are selectable.
    case Face = 0x2
}

/// Defines what the current tool interacts with in the scene view.
internal enum EditLevel: UInt8 {
    /// The transform tools interact with GameObjects.
    case Top = 0
    /// The current tool interacts with mesh geometry (faces, edges, vertices).
    case Geometry = 1
    /// Tools are affecting mesh UVs. This corresponds to UVEditor in-scene editing.
    case Texture = 2
    /// A custom ProBuilder tool mode is engaged.
    case Plugin = 3
}

/// Determines what GameObject flags this object will have.
enum EntityType {
    case Detail
    case Occluder
    case Trigger
    case Collider
    case Mover
}

enum ColliderType {
    case None
    case BoxCollider
    case MeshCollider
}

/// Axis used in projecting UVs.
public enum ProjectionAxis {
    /// Projects on x axis.
    case X
    /// Projects on y axis.
    case Y
    /// Projects on z axis.
    case Z
    /// Projects on -x axis.
    case XNegative
    /// Projects on -y axis.
    case YNegative
    /// Projects on -z axis.
    case ZNegative
}

public struct HandleAxis: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let X = HandleAxis(rawValue: 1 << 0)
    public static let Y = HandleAxis(rawValue: 1 << 1)
    public static let Z = HandleAxis(rawValue: 1 << 2)
    public static let Free = HandleAxis(rawValue: 1 << 3)
}

/// Human readable axis enum.
public enum Axis {
    /// X axis.
    case Right
    /// -X axis.
    case Left
    /// Y axis.
    case Up
    /// -Y axis.
    case Down
    /// Z axis.
    case Forward
    /// -Z axis.
    case Backward
}

/// Describes the winding order of mesh triangles.
public enum WindingOrder {
    /// Winding order could not be determined.
    case Unknown
    /// Winding is clockwise (right handed).
    case Clockwise
    /// Winding is counter-clockwise (left handed).
    case CounterClockwise
}

/// Describes methods of sorting points in 2d space.
public enum SortMethod {
    /// Order the vertices clockwise.
    case Clockwise
    /// Order the vertices counter-clockwise.
    case CounterClockwise
}

/// A flag which sets the triangle culling mode.
public struct CullingMode: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Both front and back faces are rendered.
    public static let None = CullingMode(rawValue: 0 << 0)
    /// Back faces are culled.
    public static let Back = CullingMode(rawValue: 1 << 0)
    /// Front faces are culled.
    public static let Front = CullingMode(rawValue: 1 << 1)
    /// Both front and back faces are culled.
    public static let FrontBack = [Front, Back]
}

/// Defines the behavior of drag selection in the scene view for mesh elements.
public enum RectSelectMode {
    /// Any mesh element touching the drag rectangle is selected.
    case Partial
    /// Mesh elements must be completely enveloped by the drag rect to be selected.
    case Complete
}

/// Describes why a @"UnityEngine.ProBuilder.ProBuilderMesh" is considered to be out of sync with it's UnityEngine.MeshFilter component.
public enum MeshSyncState {
    /// The MeshFilter mesh is null.
    case Null
    /// The MeshFilter mesh is not owned by the ProBuilderMesh component. Use @"UnityEngine.ProBuilder.ProBuilderMesh.MakeUnique" to remedy.
    case InstanceIDMismatch
    /// The mesh is valid, but does not have a UV2 channel.
    case Lightmap
    /// The mesh is in sync.
    case InSync
}

/// Mesh attributes bitmask.
public struct MeshArrays: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Vertex positions.
    public static let Position = MeshArrays(rawValue: 0x1)
    /// First UV channel.
    public static let Texture0 = MeshArrays(rawValue: 0x2)
    /// Second UV channel. Commonly called UV2 or Lightmap UVs in Unity terms.
    public static let Texture1 = MeshArrays(rawValue: 0x4)
    /// Second UV channel. Commonly called UV2 or Lightmap UVs in Unity terms.
    public static let Lightmap = MeshArrays(rawValue: 0x4)
    /// Third UV channel.
    public static let Texture2 = MeshArrays(rawValue: 0x8)
    /// Vertex UV4.
    public static let Texture3 = MeshArrays(rawValue: 0x10)
    /// Vertex colors.
    public static let Color = MeshArrays(rawValue: 0x20)
    /// Vertex normals.
    public static let Normal = MeshArrays(rawValue: 0x40)
    /// Vertex tangents.
    public static let Tangent = MeshArrays(rawValue: 0x80)
    /// All ProBuilder stored mesh attributes.
    public static let All = MeshArrays(rawValue: 0xFF)
}

enum IndexFormat: UInt8 {
    case Local = 0x0
    case Common = 0x1
    case Both = 0x2
}

/// Selectively rebuild and apply mesh attributes to the UnityEngine.Mesh asset.
public struct RefreshMask: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Textures channel will be rebuilt.
    public static let UV = RefreshMask(rawValue: 0x1)
    /// Colors will be rebuilt.
    public static let Colors = RefreshMask(rawValue: 0x2)
    /// Normals will be recalculated and applied.
    public static let Normals = RefreshMask(rawValue: 0x4)
    /// Tangents will be recalculated and applied.
    public static let Tangents = RefreshMask(rawValue: 0x8)
    /// Re-assign the MeshCollider sharedMesh.
    public static let Collisions = RefreshMask(rawValue: 0x10)
    /// Bounds will be recalculated.
    public static let Bounds = RefreshMask(rawValue: 0x16)
    /// Refresh all optional mesh attributes.
    public static let All: RefreshMask = [UV, Colors, Normals, Tangents, Collisions, Bounds]
}

/// Describes the different methods of face extrusion.
public enum ExtrudeMethod: UInt8 {
    /// Each face is extruded separately.
    case IndividualFaces = 0
    /// Adjacent faces are merged as a group along the averaged normals.
    case VertexNormal = 1
    /// Adjacent faces are merged as a group, but faces are extruded from each face normal.
    case FaceNormal = 2
}
