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
        let renderer = element.renderer
        let material = element.material
        let camera = pipeline.camera
        let scene = camera.scene
        let renderCount = renderer.engine._renderCount

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        prepare(pipelineDescriptor, depthStencilDescriptor)

        ShaderMacroCollection.unionCollection(material.shaderData._macroCollection,
                element.renderer._globalShaderMacro, shaderMacro)

        let functions = pipeline._resourceCache.requestShaderModule(element.shaderPass, shaderMacro)
        pipelineDescriptor.vertexFunction = functions[0]
        if functions.count == 2 {
            pipelineDescriptor.fragmentFunction = functions[1]
        }

        pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
        element.shaderPass.renderState!._apply(pipelineDescriptor, depthStencilDescriptor, encoder,
                                               element.renderer.entity.transform._isFrontFaceInvert())
        encoder.setDepthStencilState(pipeline._resourceCache.requestDepthStencilState(depthStencilDescriptor))
        let pso = pipeline._resourceCache.requestGraphicsPipeline(pipelineDescriptor)
        encoder.setRenderPipelineState(pso.handle)
        
        let switchRenderCount = renderCount != pso.uploadRenderCount
        if switchRenderCount {
            renderer.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
            material.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
            camera.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
            scene.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
            for index in 0..<31 {
                if let bufferView = mesh._vertexBufferBindings[index] {
                    encoder.setVertexBuffer(bufferView.buffer, offset: 0, index: index)
                }
            }
            
            pso.uploadRenderer = renderer
            pso.uploadScene = scene
            pso.uploadCamera = camera
            pso.uploadMaterial = material
            pso.uploadRenderCount = renderCount
            pso.uploadMesh = mesh
        } else {
            if pso.uploadScene !== scene {
                scene.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
                pso.uploadScene = scene
            }
            if pso.uploadCamera !== camera {
                camera.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
                pso.uploadCamera = camera
            }
            if pso.uploadRenderer !== renderer {
                renderer.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
                pso.uploadRenderer = renderer
            }
            if pso.uploadMaterial !== material {
                material.shaderData.bindData(encoder, pso.uniformBlock, pipeline._resourceCache)
                pso.uploadMaterial = material
            }
            if pso.uploadMesh !== mesh {
                for index in 0..<31 {
                    if let bufferView = mesh._vertexBufferBindings[index] {
                        encoder.setVertexBuffer(bufferView.buffer, offset: 0, index: index)
                    }
                }
                pso.uploadMesh = mesh
            }
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
