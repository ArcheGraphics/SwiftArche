//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

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

    func prepare(_ encoder: MTLRenderCommandEncoder) {
        let pipeline = _renderPass.pipeline!

        _pipelineDescriptor.label = "Skybox Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        _pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        _pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8

        let functions = pipeline._resourceCache.requestShaderModule(material.shader[0], _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
        material.shader[0].renderState!._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = pipeline._resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = pipeline._resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }

    override func draw(_ encoder: MTLRenderCommandEncoder) {
        if (material == nil) {
            logger.warning("The material of sky is not defined.")
            return
        }
        if (mesh == nil) {
            logger.warning("The mesh of sky is not defined.")
            return
        }

        encoder.pushDebugGroup("SkyBox")
        if (_pso == nil) {
            prepare(encoder)
        }

        let pipeline = _renderPass.pipeline!
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
        encoder.setVertexBytes(&viewProjMatrix, length: MemoryLayout<Matrix>.stride, index: 10)
        material.shaderData.bindData(encoder, _pso.uniformBlock, pipeline._resourceCache)
        encoder.setRenderPipelineState(_pso.handle)
        encoder.setDepthStencilState(_depthStencilState)

        var index = 0
        for buffer in mesh._vertexBufferBindings {
            encoder.setVertexBuffer(buffer?.buffer, offset: 0, index: index)
            index += 1
        }

        let subMesh = mesh.subMesh!
        let indexBufferBinding = mesh._indexBufferBinding
        if indexBufferBinding != nil {
            encoder.drawIndexedPrimitives(type: subMesh.topology, indexCount: subMesh.count,
                    indexType: indexBufferBinding!.format, indexBuffer: indexBufferBinding!.buffer,
                    indexBufferOffset: 0, instanceCount: mesh._instanceCount)
        } else {
            encoder.drawPrimitives(type: subMesh.topology, vertexStart: subMesh.start,
                    vertexCount: subMesh.count, instanceCount: mesh._instanceCount)
        }
        encoder.popDebugGroup()
    }
}
