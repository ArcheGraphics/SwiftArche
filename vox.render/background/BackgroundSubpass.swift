//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class BackgroundSubpass: Subpass {
    var _textureFillMode: BackgroundTextureFillMode = BackgroundTextureFillMode.AspectFitHeight
    var _mesh: ModelMesh!

    private var _canvas: Canvas

    /// Background texture.
    /// - Remark: When `mode` is `BackgroundMode.Texture`, the property will take effects.
    public var _texture: MTLTexture?

    /// Background texture fill mode.
    /// - Remark: When `mode` is `BackgroundMode.Texture`, the property will take effects.
    /// @defaultValue `BackgroundTextureFillMode.FitHeight`
    public var textureFillMode: BackgroundTextureFillMode {
        get {
            _textureFillMode
        }
        set {
            _textureFillMode = newValue
            _resizeBackgroundTexture()
        }
    }

    /// Constructor of Background.
    /// - Parameter engine:  Engine Which the background belongs to.
    public init(_ engine: Engine) {
        _canvas = engine.canvas
        super.init()
        _mesh = _createPlane(engine)
    }

    private func _resizeBackgroundTexture() {
        if (_texture == nil) {
            return
        }
        let width = _canvas.bounds.size.width
        let height = _canvas.bounds.size.height

        var positions = _mesh.getPositions()!

        switch (_textureFillMode) {
        case BackgroundTextureFillMode.Fill:
            _ = positions[0].set(x: -1, y: -1, z: 1)
            _ = positions[1].set(x: 1, y: -1, z: 1)
            _ = positions[2].set(x: -1, y: 1, z: 1)
            _ = positions[3].set(x: 1, y: 1, z: 1)
            break
        case BackgroundTextureFillMode.AspectFitWidth:
            let fitWidthScale = Float((Double(_texture!.height) * width) / Double(_texture!.width) / height)
            _ = positions[0].set(x: -1, y: -fitWidthScale, z: 1)
            _ = positions[1].set(x: 1, y: -fitWidthScale, z: 1)
            _ = positions[2].set(x: -1, y: fitWidthScale, z: 1)
            _ = positions[3].set(x: 1, y: fitWidthScale, z: 1)
            break
        case BackgroundTextureFillMode.AspectFitHeight:
            let fitHeightScale = Float((Double(_texture!.width) * height) / Double(_texture!.height) / width)
            _ = positions[0].set(x: -fitHeightScale, y: -1, z: 1)
            _ = positions[1].set(x: fitHeightScale, y: -1, z: 1)
            _ = positions[2].set(x: -fitHeightScale, y: 1, z: 1)
            _ = positions[3].set(x: fitHeightScale, y: 1, z: 1)
            break
        }
        _mesh.setPositions(positions: positions)
        _mesh.uploadData(false)
    }

    private func _createPlane(_ engine: Engine) -> ModelMesh {
        let mesh = ModelMesh(engine)
        let indices: [UInt16] = [1, 2, 0, 1, 3, 2]

        var positions = [Vector3](repeating: Vector3(), count: 4)
        var uvs = [Vector2](repeating: Vector2(), count: 4)

        for i in 0..<4 {
            positions[i] = Vector3()
            uvs[i] = Vector2(Float(i % 2), 1.0 - Float(Int(Float(i) * 0.5) | 0))
        }

        mesh.setPositions(positions: positions)
        mesh.setUVs(uv: uvs)
        mesh.setIndices(indices: indices)

        mesh.uploadData(false)
        _ = mesh.addSubMesh(0, indices.count)
        return mesh
    }
}