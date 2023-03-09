//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

class TextBatcher: Batcher {
    struct BatcherData {
        let device: MTLDevice
        
        var position: BufferView?
        var uv: BufferView?
        var indices: BufferView?
        var count: Int = 0
        var material: Material!
        var shaderPass: ShaderPass!
        var renderer: Renderer!
        var texture: MTLTexture!
        
        var verticeArray: [Vector3] = []
        var uvArray: [Vector2] = []
        var indexArray: [UInt32] = []
        
        mutating func reset() {
            verticeArray = []
            uvArray = []
            indexArray = []
            
            count = 0
        }
        
        mutating func syncToGPU() {
            if position?.count ?? 0 > verticeArray.count {
                position!.assign(with: verticeArray)
            } else {
                position = BufferView(device: device, array: verticeArray)
            }
            
            if uv?.count ?? 0 > uvArray.count {
                uv!.assign(with: uvArray)
            } else {
                uv = BufferView(device: device, array: uvArray)
            }
            
            if indices?.count ?? 0 > indexArray.count {
                indices!.assign(with: indexArray)
            } else {
                indices = BufferView(device: device, array: indexArray)
            }
        }
    }
    
    var batcherBuffer: [BatcherData] = []
    var currentBufferCount: Int = 0
    var shaderMacro = ShaderMacroCollection()
    private var _batchedQueue: [RenderElement] = []
    private let _descriptor = MTLVertexDescriptor()
    private var _engine: Engine

    init(_ engine: Engine) {
        _engine = engine
    }
    
    func appendElement(_ element: RenderElement) {
        _batchedQueue.append(element)
    }
    
    func flush() {
        currentBufferCount = 0
        for i in 0..<batcherBuffer.count {
            batcherBuffer[i].reset()
        }
        _batchedQueue = []
    }
    
    func canBatch(preElement: RenderElement, curElement: RenderElement) -> Bool {
        let preRenderer = preElement.renderer as! TextRenderer
        let curRenderer = curElement.renderer as! TextRenderer
        
        // Compare mask
        if (!checkBatchWithMask(preRenderer, curRenderer)) {
            return false
        }
        
        if preRenderer.color != curRenderer.color {
            return false
        }
        
        // Compare texture
        if (preElement.texture !== curElement.texture) {
            return false
        }

        // Compare material
        return preElement.material === curElement.material
    }
    
    func checkBatchWithMask(_ left: TextRenderer, _ right: TextRenderer) -> Bool {
        left.maskLayer == right.maskLayer
    }
    
    func _updateData() {
        var preElement: RenderElement?
        for curElement in _batchedQueue {
            if preElement != nil && !canBatch(preElement: preElement!, curElement: curElement) {
                batcherBuffer[currentBufferCount].syncToGPU()
                currentBufferCount += 1
            }
            _addBatchData(curElement, at: currentBufferCount)
            preElement = curElement
        }
        batcherBuffer[currentBufferCount].syncToGPU()
    }
    
    func _addBatchData(_ element: RenderElement, at currentBufferCount: Int) {
        let textRenderer = element.renderer as! TextRenderer
        if currentBufferCount >= batcherBuffer.count {
            var batcherData = BatcherData(device: _engine.device)
            batcherData.renderer = textRenderer
            batcherData.material = element.material
            batcherData.shaderPass = element.shaderPass
            batcherData.texture = textRenderer.fontAtlas!.fontAtlasTexture
            
            batcherData.verticeArray.append(contentsOf: textRenderer.worldVertice)
            batcherData.uvArray.append(contentsOf: textRenderer.texCoords)
            batcherData.indexArray.append(contentsOf: textRenderer.indices)
            batcherData.count += textRenderer.indices.count
            batcherBuffer.append(batcherData)
        } else {
            batcherBuffer[currentBufferCount].renderer = textRenderer
            batcherBuffer[currentBufferCount].material = element.material
            batcherBuffer[currentBufferCount].shaderPass = element.shaderPass
            batcherBuffer[currentBufferCount].texture = textRenderer.fontAtlas!.fontAtlasTexture
            let offset = batcherBuffer[currentBufferCount].verticeArray.count
            batcherBuffer[currentBufferCount].verticeArray.append(contentsOf: textRenderer.worldVertice)
            batcherBuffer[currentBufferCount].uvArray.append(contentsOf: textRenderer.texCoords)
            batcherBuffer[currentBufferCount].indexArray.append(contentsOf: textRenderer.indices.map({ v in
                v + UInt32(offset)
            }))
            batcherBuffer[currentBufferCount].count += textRenderer.indices.count
        }
    }
    
    public func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                        _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        pipelineDescriptor.label = "Forward Pipeline"
        pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            pipelineDescriptor.stencilAttachmentPixelFormat = format
        }
        
        var desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 0
        _descriptor.attributes[Int(Position.rawValue)] = desc
        _descriptor.layouts[0].stride = MemoryLayout<Vector3>.stride

        desc = MTLVertexAttributeDescriptor()
        desc.format = .float2
        desc.offset = 0
        desc.bufferIndex = 1
        _descriptor.attributes[Int(UV_0.rawValue)] = desc
        _descriptor.layouts[1].stride = MemoryLayout<Vector2>.stride
    }

    override func drawBatcher(_ encoder: inout RenderCommandEncoder, _ camera: Camera, _ cache: ResourceCache) {
        if !_batchedQueue.isEmpty {
            _updateData()
            for data in batcherBuffer {
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                let depthStencilDescriptor = MTLDepthStencilDescriptor()
                prepare(pipelineDescriptor, depthStencilDescriptor)
                
                ShaderMacroCollection.unionCollection(data.material.shaderData._macroCollection,
                                                      data.renderer._globalShaderMacro, shaderMacro)
                
                let functions = cache.requestShaderModule(data.shaderPass, shaderMacro)
                pipelineDescriptor.vertexFunction = functions[0]
                pipelineDescriptor.fragmentFunction = functions[1]
                pipelineDescriptor.vertexDescriptor = _descriptor
                data.shaderPass.renderState!._apply(pipelineDescriptor, depthStencilDescriptor, encoder.handle,
                                                    data.renderer.entity.transform._isFrontFaceInvert())
                
                let pso = cache.requestGraphicsPipeline(pipelineDescriptor)
                encoder.bind(depthStencilState: depthStencilDescriptor, cache)
                encoder.bind(camera: camera, pso, cache)
                encoder.bind(material: data.material, pso, cache)
                encoder.bind(renderer: data.renderer, pso, cache)
                encoder.bind(scene: camera.scene, pso, cache)
                
                encoder.handle.setFragmentTexture(data.texture, index: 0)
                encoder.handle.setVertexBuffer(data.position!.buffer, offset: 0, index: 0)
                encoder.handle.setVertexBuffer(data.uv!.buffer, offset: 0, index: 1)
                encoder.handle.drawIndexedPrimitives(type: .triangle, indexCount: data.count, indexType: .uint32,
                                                     indexBuffer: data.indices!.buffer, indexBufferOffset: 0)
            }
            flush()
        }
    }
}