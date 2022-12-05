//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public struct RenderCommandEncoder {
    public let descriptor: MTLRenderPassDescriptor
    public let handle: MTLRenderCommandEncoder

    private var _uploadScene: Scene?
    private var _uploadCamera: Camera?
    private var _uploadRenderer: Renderer?
    private var _uploadMaterial: Material?
    private var _uploadMesh: Mesh?
    private var _uploadPSO: RenderPipelineState?
    private var _uploadDepthStencilState: MTLDepthStencilState?

    init(_ commandBuffer: MTLCommandBuffer, _ descriptor: MTLRenderPassDescriptor, _ label: String = "") {
        self.descriptor = descriptor
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Render command encoder failed")
        }
        handle = encoder
        handle.label = label
    }

    public mutating func bind(depthStencilState: MTLDepthStencilDescriptor, _ cache: ResourceCache) {
        let state = cache.requestDepthStencilState(depthStencilState)
        if _uploadDepthStencilState !== state {
            handle.setDepthStencilState(state)
            _uploadDepthStencilState = state
        }
    }

    public mutating func bind(camera: Camera, _ pso: RenderPipelineState, _ cache: ResourceCache) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadCamera !== camera {
            camera.shaderData.bindData(handle, pso.uniformBlock, cache)
            _uploadCamera = camera
        }
        camera.shaderData.bindDynamicData(handle, pso.uniformBlock, cache)
    }

    public mutating func bind(material: Material, _ pso: RenderPipelineState, _ cache: ResourceCache) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadMaterial !== material {
            material.shaderData.bindData(handle, pso.uniformBlock, cache)
            _uploadMaterial = material
        }
        material.shaderData.bindDynamicData(handle, pso.uniformBlock, cache)
    }

    public mutating func bind(renderer: Renderer, _ pso: RenderPipelineState, _ cache: ResourceCache) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadRenderer !== renderer {
            renderer.shaderData.bindData(handle, pso.uniformBlock, cache)
            _uploadRenderer = renderer
        }
        renderer.shaderData.bindDynamicData(handle, pso.uniformBlock, cache)
    }

    public mutating func bind(scene: Scene, _ pso: RenderPipelineState, _ cache: ResourceCache) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadScene !== scene {
            scene.shaderData.bindData(handle, pso.uniformBlock, cache)
            _uploadScene = scene
        }
        scene.shaderData.bindDynamicData(handle, pso.uniformBlock, cache)
    }

    public mutating func bind(mesh: Mesh) {
        if _uploadMesh !== mesh {
            for index in 0..<31 {
                if let bufferView = mesh._vertexBufferBindings[index] {
                    handle.setVertexBuffer(bufferView.buffer, offset: 0, index: index)
                }
            }
            _uploadMesh = mesh
        }
    }

    public mutating func draw(subMesh: SubMesh, with mesh: Mesh) {
        let indexBufferBinding = mesh._indexBufferBinding
        if indexBufferBinding != nil {
            handle.drawIndexedPrimitives(type: subMesh.topology, indexCount: subMesh.count,
                    indexType: indexBufferBinding!.format, indexBuffer: indexBufferBinding!.buffer,
                    indexBufferOffset: 0, instanceCount: mesh._instanceCount)
        } else {
            handle.drawPrimitives(type: subMesh.topology, vertexStart: subMesh.start,
                    vertexCount: subMesh.count, instanceCount: mesh._instanceCount)
        }
    }

    public func endEncoding() {
        handle.endEncoding()
    }

    private mutating func _bind(pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            handle.setRenderPipelineState(pso.handle)
            _uploadPSO = pso
            _uploadCamera = nil
            _uploadRenderer = nil
            _uploadScene = nil
            _uploadMaterial = nil
        }
    }
}
