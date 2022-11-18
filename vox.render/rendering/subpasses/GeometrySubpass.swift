//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class GeometrySubpass: Subpass {
    var shaderMacro = ShaderMacroCollection()

    func drawElement(_ encoder: MTLRenderCommandEncoder) {
        // rewrite by subclass
    }

    func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                 _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        // rewrite by subclass
    }

    override func draw(_ encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("Draw Element")
        drawElement(encoder)
        encoder.popDebugGroup()
    }

    func _drawElement(_ encoder: MTLRenderCommandEncoder, _ element: RenderElement) {
        let pipeline = _renderPass.pipeline!
        let mesh = element.mesh
        let subMesh = element.subMesh

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        prepare(pipelineDescriptor, depthStencilDescriptor)

        ShaderMacroCollection.unionCollection(element.material.shaderData._macroCollection,
                element.renderer.shaderData._macroCollection, shaderMacro)

        let functions = pipeline._resourceCache.requestShaderModule(element.shaderPass, shaderMacro)
        pipelineDescriptor.vertexFunction = functions[0]
        if functions.count == 2 {
            pipelineDescriptor.fragmentFunction = functions[1]
        }

        pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
        element.shaderPass.renderState!._apply(pipelineDescriptor, depthStencilDescriptor, encoder, false)

        let pso = pipeline._resourceCache.requestGraphicsPipeline(pipelineDescriptor)
        element.renderer.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
        element.material.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
        pipeline.camera.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
        pipeline.camera.scene.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
        encoder.setRenderPipelineState(pso.handle)

        encoder.setDepthStencilState(pipeline._resourceCache.requestDepthStencilState(depthStencilDescriptor))
        var index = 0
        for buffer in mesh._vertexBufferBindings {
            encoder.setVertexBuffer(buffer?.buffer, offset: 0, index: index)
            index += 1
        }

        let indexBufferBinding = mesh._indexBufferBinding
        if indexBufferBinding != nil {
            encoder.drawIndexedPrimitives(type: subMesh.topology, indexCount: subMesh.count,
                    indexType: indexBufferBinding!.format, indexBuffer: indexBufferBinding!.buffer,
                    indexBufferOffset: 0, instanceCount: mesh._instanceCount)
        } else {
            encoder.drawPrimitives(type: subMesh.topology, vertexStart: subMesh.start,
                    vertexCount: subMesh.count, instanceCount: mesh._instanceCount)
        }
    }
}