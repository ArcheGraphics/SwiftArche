//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class GeometrySubpass: Subpass {
    open func drawElement(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder) {
        // rewrite by subclass
    }

    open func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                      _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        // rewrite by subclass
    }

    open override func draw(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder) {
        encoder.handle.pushDebugGroup("Draw Element")
        drawElement(pipeline: pipeline, on: &encoder)
        encoder.handle.popDebugGroup()
    }

    public func _drawElement(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder, _ element: RenderElement) {
        let mesh = element.mesh
        let renderer = element.renderer
        let material = element.material
        let camera = pipeline.camera

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        prepare(pipelineDescriptor, depthStencilDescriptor)
        
        var shaderMacro = Engine.fg.frameData._macroCollection
        ShaderMacroCollection.unionCollection(material.shaderData._macroCollection,
                renderer._globalShaderMacro, &shaderMacro)

        let functions = Engine.resourceCache.requestShaderModule(element.shaderPass, shaderMacro)
        pipelineDescriptor.vertexFunction = functions[0]
        if functions.count == 2 {
            pipelineDescriptor.fragmentFunction = functions[1]
        }
        if let mesh {
            pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
            element.shaderPass.renderState!._apply(pipelineDescriptor, depthStencilDescriptor, encoder.handle,
                                                   renderer.entity.transform._isFrontFaceInvert())
            
            let pso = Engine.resourceCache.requestGraphicsPipeline(pipelineDescriptor)
            encoder.bind(depthStencilState: depthStencilDescriptor)
            encoder.bind(camera: camera, pso)
            encoder.bind(material: material, pso)
            encoder.bind(renderer: renderer, pso)
            encoder.bind(scene: camera.scene, pso)
            encoder.bind(fg: Engine.fg, pso)
            encoder.bind(mesh: mesh)
            encoder.draw(subMesh: element.subMesh!, with: mesh)
        }
    }
    
    public func _drawBatcher<B: Batcher>(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder, _ batcher: B) {
        batcher.drawBatcher(&encoder, pipeline.camera)
    }
}
