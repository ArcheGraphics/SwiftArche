//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

final class ProBuilderShape: Script {
    var m_Shape: Shape = Cube()

    var m_Size = Vector3.one

    var m_Rotation = Quaternion()

    var m_Mesh: ProBuilderMesh?

    var m_PivotLocation: PivotLocation = .Center

    var m_PivotPosition = Vector3()

    internal var m_UnmodifiedMeshVersion: UInt8 = 0

    public var shape: Shape {
        get {
            m_Shape
        }
        set {
            m_Shape = newValue
        }
    }

    public var pivotLocation: PivotLocation {
        get {
            m_PivotLocation
        }
        set {
            m_PivotLocation = newValue
        }
    }

    public var pivotLocalPosition: Vector3 {
        get {
            m_PivotPosition
        }
        set {
            m_PivotPosition = newValue
        }
    }

    public var pivotGlobalPosition: Vector3 {
        get {
            Vector3()
        }
        set {

        }
    }

    public var size: Vector3 {
        get {
            m_Size
        }
        set {
        }
    }

    public var rotation: Quaternion {
        get {
            m_Rotation
        }
        set {
            m_Rotation = newValue
        }
    }

    var m_EditionBounds = Bounds()
    public var editionBounds: Bounds {
        get {
            Bounds()
        }
    }

    var m_ShapeBox = Bounds()
    public var shapeBox: Bounds {
        get {
            m_ShapeBox
        }
    }

    public var isEditable: Bool {
        m_UnmodifiedMeshVersion == mesh?.versionIndex
    }

    /// Reference to the <see cref="ProBuilderMesh"/> that this component is creating.
    public var mesh: ProBuilderMesh? {
        get {
            m_Mesh
        }
    }

    func OnValidate() {
    }

    internal func UpdateComponent() {
    }

    internal func UpdateBounds(_ bounds: Bounds) {
    }

    internal func Rebuild(bounds: Bounds, rotation: Quaternion, cornerPivot: Vector3) {
    }

    func Rebuild() {
    }

    internal func SetShape(_ shape: Shape, location: PivotLocation) {
    }

    /// Rotates the Shape by a given quaternion while respecting the bounds
    internal func RotateInsideBounds(deltaRotation: Quaternion) {
    }

    func ResetPivot(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) {
    }


    func RebuildPivot(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) {
    }
}
