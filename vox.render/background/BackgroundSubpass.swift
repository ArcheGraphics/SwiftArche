//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

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
    public override init() {
        _canvas = Engine.canvas
        _shader = ShaderPass(Engine.library(), "vertex_background", "fragment_background")
        _shader.renderState!.depthState.compareFunction = MTLCompareFunction.lessEqual
        super.init()
        _mesh = _createPlane()
    }

    func prepare(pipeline: DevicePipeline, on encoder: MTLRenderCommandEncoder) {
        _pipelineDescriptor.label = "Background Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            _pipelineDescriptor.stencilAttachmentPixelFormat = format
        }

        let functions = Engine.resourceCache.requestShaderModule(_shader, _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = _mesh._vertexDescriptor
        _shader.renderState!._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = Engine.resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = Engine.resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }

    public override func draw(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder) {
        encoder.handle.pushDebugGroup("Background")
        if (_pso == nil) {
            prepare(pipeline: pipeline, on: encoder.handle)
        }

        encoder.handle.setRenderPipelineState(_pso.handle)
        encoder.handle.setDepthStencilState(_depthStencilState)
        encoder.bind(mesh: _mesh)
        encoder.draw(subMesh: _mesh.subMesh!, with: _mesh)
        encoder.handle.popDebugGroup()
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
            positions[0] = Vector3(-1, -1, 1)
            positions[1] = Vector3(1, -1, 1)
            positions[2] = Vector3(-1, 1, 1)
            positions[3] = Vector3(1, 1, 1)
            break
        case BackgroundTextureFillMode.AspectFitWidth:
            let fitWidthScale = Float((Double(_texture!.height) * width) / Double(_texture!.width) / height)
            positions[0] = Vector3(-1, -fitWidthScale, 1)
            positions[1] = Vector3(1, -fitWidthScale, 1)
            positions[2] = Vector3(-1, fitWidthScale, 1)
            positions[3] = Vector3(1, fitWidthScale, 1)
            break
        case BackgroundTextureFillMode.AspectFitHeight:
            let fitHeightScale = Float((Double(_texture!.width) * height) / Double(_texture!.height) / width)
            positions[0] = Vector3(-fitHeightScale, -1, 1)
            positions[1] = Vector3(fitHeightScale, -1, 1)
            positions[2] = Vector3(-fitHeightScale, 1, 1)
            positions[3] = Vector3(fitHeightScale, 1, 1)
            break
        }
        _mesh.setPositions(positions: positions)
        _mesh.uploadData(false)
    }

    private func _createPlane() -> ModelMesh {
        let mesh = ModelMesh()
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
