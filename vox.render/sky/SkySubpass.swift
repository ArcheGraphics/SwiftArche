//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

public class SkySubpass: Subpass {
    private static var _epsilon: Float = 1e-6

    /// Material of the sky.
    public var material: SkyBoxMaterial!
    /// Mesh of the sky.
    public var mesh: Mesh!

    private let _shaderMacro = ShaderMacroCollection()
    private let _depthStencilDescriptor = MTLDepthStencilDescriptor()
    private let _pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var _pso: RenderPipelineState!
    private var _depthStencilState: MTLDepthStencilState!
    
    public override init() {
        super.init()
    }

    func prepare(pipeline: DevicePipeline, on encoder: MTLRenderCommandEncoder) {
        _pipelineDescriptor.label = "Skybox Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            _pipelineDescriptor.stencilAttachmentPixelFormat = format
        }

        let functions = Engine.resourceCache.requestShaderModule(material.shader.subShaders[0].passes[0], _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
        material.renderStates[0]._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = Engine.resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = Engine.resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }

    public override func draw(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder) {
        if (material == nil) {
            logger.warning("The material of sky is not defined.")
            return
        }
        if (mesh == nil) {
            logger.warning("The mesh of sky is not defined.")
            return
        }

        encoder.handle.pushDebugGroup("SkyBox")
        if (_pso == nil) {
            prepare(pipeline: pipeline, on: encoder.handle)
        }

        let camera = pipeline.camera

        // MARK: - Infinity Projection Matrix
        var viewProjMatrix = camera.viewMatrix
        viewProjMatrix.elements.columns.3[0] = 0
        viewProjMatrix.elements.columns.3[1] = 0
        viewProjMatrix.elements.columns.3[2] = 0

        var projectionMatrix: Matrix = Matrix(
                m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: SkySubpass._epsilon - 1, m34: -1,
                m41: 0, m42: 0, m43: 0, m44: 0
        )
        // epsilon-infinity projection matrix http://terathon.com/gdc07_lengyel.pdf
        let f = 1.0 / tan(MathUtil.degreeToRadian(camera.fieldOfView) / 2)
        projectionMatrix.elements.columns.0[0] = f / camera.aspectRatio
        projectionMatrix.elements.columns.1[1] = f

        viewProjMatrix = projectionMatrix * viewProjMatrix
        encoder.handle.setVertexBytes(&viewProjMatrix, length: MemoryLayout<Matrix>.stride, index: 10)
        encoder.bind(material: material, _pso)
        encoder.bind(mesh: mesh)
        encoder.handle.setDepthStencilState(_depthStencilState)
        encoder.handle.setFrontFacing(.clockwise)
        encoder.handle.setCullMode(.back)
        encoder.draw(subMesh: mesh.subMesh!, with: mesh)

        encoder.handle.popDebugGroup()
    }
}
