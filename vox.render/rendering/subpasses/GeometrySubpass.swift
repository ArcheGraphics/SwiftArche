//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class GeometrySubpass: Subpass {
    open func drawElement(pipeline _: DevicePipeline, on _: inout RenderCommandEncoder) {
        // rewrite by subclass
    }

    open func prepare(_: MTLRenderPipelineDescriptor,
                      _: MTLDepthStencilDescriptor)
    {
        // rewrite by subclass
    }

    override open func draw(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder) {
        encoder.handle.pushDebugGroup("Draw Element")
        drawElement(pipeline: pipeline, on: &encoder)
        encoder.handle.popDebugGroup()
    }

    public func _drawElement(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder, _ element: RenderElement) {
        switch element.data.renderType {
        case .Mesh:
            _drawMesh(pipeline: pipeline, on: &encoder, renderState: element.renderState,
                      shaderPass: element.shaderPass, meshRenderData: element.data as! MeshRenderData)
        case .Text:
            TextBatcher.ins.appendElement(element)
        case .Terrian:
            break
        }
    }

    public func _drawMesh(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder,
                          renderState: RenderState, shaderPass: ShaderPass, meshRenderData: MeshRenderData)
    {
        let mesh = meshRenderData.mesh
        let renderer = meshRenderData.renderer
        let material = meshRenderData.material
        let camera = pipeline.camera

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        prepare(pipelineDescriptor, depthStencilDescriptor)

        let frameData = Engine.fg.frameData
        ShaderMacroCollection.unionCollection(frameData._macroCollection,
                                              renderer._globalShaderMacro, &frameData._macroCollection)
        ShaderMacroCollection.unionCollection(frameData._macroCollection,
                                              material.shaderData._macroCollection, &frameData._macroCollection)

        let functions = Engine.resourceCache.requestShaderModule(shaderPass, frameData._macroCollection)
        pipelineDescriptor.vertexFunction = functions[0]
        if functions.count == 2 {
            pipelineDescriptor.fragmentFunction = functions[1]
        }
        pipelineDescriptor.vertexDescriptor = mesh._vertexDescriptor
        renderState._apply(pipelineDescriptor, depthStencilDescriptor, encoder.handle,
                           renderer.entity.transform._isFrontFaceInvert())

        let pso = Engine.resourceCache.requestGraphicsPipeline(pipelineDescriptor)
        encoder.bind(depthStencilState: depthStencilDescriptor)
        encoder.bind(camera: camera, pso)
        encoder.bind(material: material, pso)
        encoder.bind(renderer: renderer, pso)
        encoder.bind(scene: camera.scene, pso)
        encoder.bind(fg: Engine.fg, pso)
        encoder.bind(mesh: mesh)
        encoder.draw(subMesh: meshRenderData.subMesh, with: mesh)
    }

    public func _drawBatcher<B: Batcher>(pipeline: DevicePipeline, on encoder: inout RenderCommandEncoder, _ batcher: B) {
        batcher.drawBatcher(&encoder, pipeline.camera)
    }
}
