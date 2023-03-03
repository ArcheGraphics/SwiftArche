//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// PolyShape is a component that handles the creation of <see cref="ProBuilderMesh"/> shapes from a set of contiguous points.
public final class PolyShape: Script {
    /// Describes the different input states this tool operates in.
    internal enum PolyEditMode {
        case None
        case Path
        case Height
        case Edit
    }

    var m_Mesh: ProBuilderMesh?

    internal var m_Points: [Vector3] = []

    var m_Extrude: Float = 0

    var m_EditMode: PolyEditMode = .None

    var m_FlipNormals: Bool = false

    internal var isOnGrid: Bool = true

    /// Get the points that form the path for the base of this shape.
    public var controlPoints: [Vector3] {
        get {
            m_Points
        }
    }

    /// Set the points that form the path for the base of this shape.
    public func SetControlPoints(_ points: [Vector3]) {
    }

    /// Set the distance that this shape should extrude from the base. After setting this value, you will need to
    /// invoke <see cref="MeshOperations.AppendElements.CreateShapeFromPolygon"/> to rebuild the <see cref="ProBuilderMesh"/> component.
    public var extrude: Float {
        get {
            m_Extrude
        }
        set {
            m_Extrude = newValue
        }
    }

    internal var polyEditMode: PolyEditMode = .None

    /// Defines what direction the normals of this shape will face. Use this to invert the normals, creating a volume with the normals facing inwards.
    public var flipNormals: Bool {
        get {
            m_FlipNormals
        }
        set {
            m_FlipNormals = newValue
        }
    }

    internal var mesh: ProBuilderMesh? {
        get {
            if (m_Mesh == nil) {
                m_Mesh = entity.getComponent(ProBuilderMesh.self)
            }

            return m_Mesh
        }

        set {
            m_Mesh = newValue
        }
    }

    /// ProGridsConditionalSnap tells pg_Editor to reflect this value.
    func IsSnapEnabled() -> Bool {
        isOnGrid
    }
}
