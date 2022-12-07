//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Grid Control
public class GridControl: Script {
    /// Create Mesh with position in clipped space.
    /// - Parameter engine:
    /// - Returns: Mesh
    static func createGridPlane(_ engine: Engine) -> ModelMesh {
        var positions: [Vector3] = []
        positions.append(Vector3(1, 1, 0))
        positions.append(Vector3(-1, -1, 0))
        positions.append(Vector3(-1, 1, 0))
        positions.append(Vector3(-1, -1, 0))
        positions.append(Vector3(1, 1, 0))
        positions.append(Vector3(1, -1, 0))

        let indices: [UInt16] = [2, 1, 0, 5, 4, 3]
        let mesh = ModelMesh(engine)
        mesh.setPositions(positions: positions)
        mesh.setIndices(indices: indices)
        mesh.uploadData(true)
        _ = mesh.addSubMesh(0, 6)
        mesh.bounds = BoundingBox(Vector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude),
                Vector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude))
        return mesh
    }

    private var _material: GridMaterial!
    private var _progress: Float = 0
    private var _is2DGrid: Bool = false
    private var _flipGrid: Bool = false

    /// Flip speed
    public var speed: Float = 10.0

    /// Camera
    public var camera: Camera?

    /// Grid Material.
    public var material: GridMaterial {
        get {
            _material
        }
    }

    /// Is 2D Grid.
    public var is2DGrid: Bool {
        get {
            _is2DGrid
        }
        set {
            _is2DGrid = newValue
            _progress = 0
            _flipGrid = true
        }
    }

    public override func onAwake() {
        let gridRenderer: MeshRenderer! = entity.addComponent()
        gridRenderer.mesh = GridControl.createGridPlane(engine)
        _material = GridMaterial(engine)
        gridRenderer.setMaterial(_material)
    }

    public override func onUpdate(_ deltaTime: Float) {
        if let camera = camera {
            material.nearClipPlane = camera.nearClipPlane
            material.farClipPlane = camera.farClipPlane

            if (_flipGrid) {
                _progress += deltaTime
                var percent = simd_clamp(_progress * speed, 0, 1)
                if (percent >= 1) {
                    _flipGrid = false
                }

                if (!_is2DGrid) {
                    percent = 1 - percent
                }
                material.flipProgress = percent
            }
        }
    }
}
