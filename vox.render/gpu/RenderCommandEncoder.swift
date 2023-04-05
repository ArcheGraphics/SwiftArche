//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public struct RenderCommandEncoder {
    public let handle: MTLRenderCommandEncoder

    public var _uploadFrameGraph: FrameGraph?
    public var _uploadScene: Scene?
    public var _uploadCamera: Camera?
    public var _uploadRenderer: Renderer?
    public var _uploadMaterial: Material?
    public var _uploadMesh: Mesh?
    public var _uploadPSO: RenderPipelineState?
    public var _uploadDepthStencilState: MTLDepthStencilState?

    init(_ commandBuffer: MTLCommandBuffer, _ descriptor: MTLRenderPassDescriptor, _ label: String = "") {
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Render command encoder failed")
        }
        handle = encoder
        handle.label = label
    }

    public mutating func bind(depthStencilState: MTLDepthStencilDescriptor) {
        let state = Engine.resourceCache.requestDepthStencilState(depthStencilState)
        if _uploadDepthStencilState !== state {
            handle.setDepthStencilState(state)
            _uploadDepthStencilState = state
        }
    }

    public mutating func bind(camera: Camera, _ pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadCamera !== camera {
            camera.shaderData.bindData(handle, pso.uniformBlock)
            _uploadCamera = camera
        }
    }

    public mutating func bind(material: Material, _ pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadMaterial !== material {
            material.shaderData.bindData(handle, pso.uniformBlock)
            _uploadMaterial = material
        }
    }

    public mutating func bind(renderer: Renderer, _ pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadRenderer !== renderer {
            renderer.shaderData.bindData(handle, pso.uniformBlock)
            _uploadRenderer = renderer
        }
    }

    public mutating func bind(scene: Scene, _ pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadScene !== scene {
            scene.shaderData.bindData(handle, pso.uniformBlock)
            _uploadScene = scene
        }
    }

    public mutating func bind(fg: FrameGraph, _ pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            _bind(pso: pso)
        }
        if _uploadFrameGraph !== fg {
            fg.frameData.bindData(handle, pso.uniformBlock)
            _uploadFrameGraph = fg
        }
    }

    public mutating func bind(mesh: Mesh) {
        if _uploadMesh !== mesh {
            for index in 0 ..< 31 {
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

    public mutating func flush() {
        _uploadCamera = nil
        _uploadRenderer = nil
        _uploadScene = nil
        _uploadMaterial = nil
        _uploadFrameGraph = nil
    }

    private mutating func _bind(pso: RenderPipelineState) {
        if _uploadPSO !== pso {
            handle.setRenderPipelineState(pso.handle)
            _uploadPSO = pso
            flush()
        }
    }
}
