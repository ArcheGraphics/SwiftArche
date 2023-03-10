//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class GeometrySubpass: Subpass {
    var shaderMacro = ShaderMacroCollection()
    
    public override init() {}

    open func drawElement(_ encoder: inout RenderCommandEncoder) {
        // rewrite by subclass
    }

    open func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                      _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        // rewrite by subclass
    }

    open override func draw(_ encoder: inout RenderCommandEncoder) {
        encoder.handle.pushDebugGroup("Draw Element")
        drawElement(&encoder)
        encoder.handle.popDebugGroup()
    }

    public func _drawElement(_ encoder: inout RenderCommandEncoder, _ element: RenderElement) {
        let pipeline = _renderPass.pipeline!
        let cache = pipeline._resourceCache
        let mesh = element.mesh
        let renderer = element.renderer
        let material = element.material
        let camera = pipeline.camera

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        prepare(pipelineDescriptor, depthStencilDescriptor)

        ShaderMacroCollection.unionCollection(material.shaderData._macroCollection,
                renderer._globalShaderMacro, shaderMacro)

        let functions = cache.requestShaderModule(element.shaderPass, shaderMacro)
        pipelineDescriptor.vertexFunction = functions[0]
        if functions.count == 2 {
            pipelineDescriptor.fragmentFunction = functions[1]
        }
        if let mesh {
            pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
            element.shaderPass.renderState!._apply(pipelineDescriptor, depthStencilDescriptor, encoder.handle,
                                                   renderer.entity.transform._isFrontFaceInvert())
            
            let pso = cache.requestGraphicsPipeline(pipelineDescriptor)
            encoder.bind(depthStencilState: depthStencilDescriptor, cache)
            encoder.bind(camera: camera, pso, cache)
            encoder.bind(material: material, pso, cache)
            encoder.bind(renderer: renderer, pso, cache)
            encoder.bind(scene: camera.scene, pso, cache)
            encoder.bind(mesh: mesh)
            encoder.draw(subMesh: element.subMesh!, with: mesh)
        }
    }
    
    public func _drawBatcher<B: Batcher>(_ encoder: inout RenderCommandEncoder, _ batcher: B) {
        let pipeline = _renderPass.pipeline!
        batcher.drawBatcher(&encoder, pipeline.camera, pipeline._resourceCache)
    }
}
