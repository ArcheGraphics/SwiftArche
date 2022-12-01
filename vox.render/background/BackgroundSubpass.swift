//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class BackgroundSubpass: Subpass {
    private var _textureFillMode: BackgroundTextureFillMode = BackgroundTextureFillMode.AspectFitHeight
    private var _mesh: ModelMesh!
    private let _canvas: Canvas
    private let _shaderMacro = ShaderMacroCollection()
    private let _depthStencilDescriptor = MTLDepthStencilDescriptor()
    private let _pipelineDescriptor = MTLRenderPipelineDescriptor()
    private let _shader: ShaderPass
    private var _pso: RenderPipelineState!
    private var _depthStencilState: MTLDepthStencilState!

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
        _shader = ShaderPass(engine.library(), "vertex_background", "fragment_background")
        _shader.renderState!.depthState.compareFunction = MTLCompareFunction.lessEqual
        super.init()
        _mesh = _createPlane(engine)
    }

    func prepare(_ encoder: MTLRenderCommandEncoder) {
        let pipeline = _renderPass.pipeline!

        _pipelineDescriptor.label = "Background Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        _pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        _pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8

        let functions = pipeline._resourceCache.requestShaderModule(_shader, _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = _mesh._vertexDescriptor
        _shader.renderState!._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = pipeline._resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = pipeline._resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }

    override func draw(_ encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("Background")
        if (_pso == nil) {
            prepare(encoder)
        }

        encoder.setRenderPipelineState(_pso.handle)
        encoder.setDepthStencilState(_depthStencilState)

        var index = 0
        for buffer in _mesh._vertexBufferBindings {
            encoder.setVertexBuffer(buffer?.buffer, offset: 0, index: index)
            index += 1
        }

        let subMesh = _mesh.subMesh!
        let indexBufferBinding = _mesh._indexBufferBinding
        encoder.drawIndexedPrimitives(type: subMesh.topology, indexCount: subMesh.count,
                indexType: indexBufferBinding!.format, indexBuffer: indexBufferBinding!.buffer,
                indexBufferOffset: 0, instanceCount: _mesh._instanceCount)

        encoder.popDebugGroup()
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
