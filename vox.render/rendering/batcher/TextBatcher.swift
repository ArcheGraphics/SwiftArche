//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

class TextBatcher: Batcher {
    static var _ins: TextBatcher!

    struct BatcherData {
        let device: MTLDevice
        
        var position: BufferView?
        var uv: BufferView?
        var indices: BufferView?
        var count: Int = 0
        var material: Material!
        var shaderPass: ShaderPass!
        var color: Color = Color()
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
    private let _descriptor = MTLVertexDescriptor()
    private var _engine: Engine!
    private var _lastColor: Color?
    private var _lastElement: RenderElement?
    private var _currentBufferIndex: Int = 0
    
    static var ins: TextBatcher {
        if _ins == nil {
            _ins = TextBatcher()
        }
        return _ins
    }
    
    var currentBufferCount: Int {
        _currentBufferIndex + 1
    }

    var containData: Bool {
        currentBufferCount != 0
    }
        
    func set(_ engine: Engine) {
        self._engine = engine
    }
    
    func appendElement(_ curElement: RenderElement) {
        if _lastElement != nil && !canBatch(preElement: _lastElement!, curElement: curElement) {
            batcherBuffer[_currentBufferIndex].syncToGPU()
            _currentBufferIndex += 1
        }
        _addBatchData(curElement, at: _currentBufferIndex)
        _lastElement = curElement
        batcherBuffer[_currentBufferIndex].syncToGPU()
    }
    
    func appendElement(vertices: [Vector3], texCoords: [Vector2], indices: [UInt32], color: Color,
                       fontAtlas: MTLTexture, material: Material) {
        if _lastColor != nil && _lastColor != color {
            batcherBuffer[_currentBufferIndex].syncToGPU()
            _currentBufferIndex += 1
        }
        _addBatchData(vertices, texCoords, indices, color, fontAtlas,
                      material, at: _currentBufferIndex)
        _lastColor = color
        batcherBuffer[_currentBufferIndex].syncToGPU()
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
    
    func _addBatchData(_ element: RenderElement, at currentBufferIndex: Int) {
        let textRenderer = element.renderer as! TextRenderer
        _addBatchData(textRenderer.worldVertice, textRenderer.texCoords, textRenderer.indices,
                      textRenderer.color, textRenderer.fontAtlas!.fontAtlasTexture,
                      element.material, at: currentBufferIndex)
    }
    
    func _addBatchData(_ vertices: [Vector3], _ texCoords: [Vector2],
                       _ indices: [UInt32], _ color: Color, _ fontAtlas: MTLTexture,
                       _ material: Material, at currentBufferIndex: Int) {
        if currentBufferCount > batcherBuffer.count {
            var batcherData = BatcherData(device: _engine.device)
            batcherData.color = color
            batcherData.material = material
            batcherData.shaderPass = material.shader[0]
            batcherData.texture = fontAtlas
            
            batcherData.verticeArray.append(contentsOf: vertices)
            batcherData.uvArray.append(contentsOf: texCoords)
            batcherData.indexArray.append(contentsOf: indices)
            batcherData.count += indices.count
            batcherBuffer.append(batcherData)
        } else {
            batcherBuffer[currentBufferIndex].color = color
            batcherBuffer[currentBufferIndex].material = material
            batcherBuffer[currentBufferIndex].shaderPass = material.shader[0]
            batcherBuffer[currentBufferIndex].texture = fontAtlas
            let offset = batcherBuffer[currentBufferIndex].verticeArray.count
            batcherBuffer[currentBufferIndex].verticeArray.append(contentsOf: vertices)
            batcherBuffer[currentBufferIndex].uvArray.append(contentsOf: texCoords)
            batcherBuffer[currentBufferIndex].indexArray.append(contentsOf: indices.map({ v in
                v + UInt32(offset)
            }))
            batcherBuffer[currentBufferIndex].count += indices.count
        }
    }
    
    // MARK: - Render
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

    func drawBatcher(_ encoder: inout RenderCommandEncoder, _ camera: Camera, _ cache: ResourceCache) {
        for i in 0..<currentBufferCount {
            if i < batcherBuffer.count && batcherBuffer[i].count != 0 {
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                let depthStencilDescriptor = MTLDepthStencilDescriptor()
                prepare(pipelineDescriptor, depthStencilDescriptor)
                
                let functions = cache.requestShaderModule(batcherBuffer[i].shaderPass,
                                                          batcherBuffer[i].material.shaderData._macroCollection)
                pipelineDescriptor.vertexFunction = functions[0]
                pipelineDescriptor.fragmentFunction = functions[1]
                pipelineDescriptor.vertexDescriptor = _descriptor
                batcherBuffer[i].shaderPass.renderState!._apply(pipelineDescriptor,
                                                                depthStencilDescriptor, encoder.handle, false)
                
                let pso = cache.requestGraphicsPipeline(pipelineDescriptor)
                encoder.bind(depthStencilState: depthStencilDescriptor, cache)
                encoder.bind(camera: camera, pso, cache)
                encoder.bind(material: batcherBuffer[i].material, pso, cache)
                encoder.bind(scene: camera.scene, pso, cache)
                
                var color = batcherBuffer[i].color
                encoder.handle.setFragmentBytes(&color, length: MemoryLayout<Color>.stride, index: 0)
                encoder.handle.setFragmentTexture(batcherBuffer[i].texture, index: 0)
                encoder.handle.setVertexBuffer(batcherBuffer[i].position!.buffer, offset: 0, index: 0)
                encoder.handle.setVertexBuffer(batcherBuffer[i].uv!.buffer, offset: 0, index: 1)
                encoder.handle.drawIndexedPrimitives(type: .triangle, indexCount: batcherBuffer[i].count, indexType: .uint32,
                                                     indexBuffer: batcherBuffer[i].indices!.buffer, indexBufferOffset: 0)
            }
        }
        flush()
    }
    
    func flush() {
        _currentBufferIndex = 0
        for i in 0..<batcherBuffer.count {
            batcherBuffer[i].reset()
        }
        _lastElement = nil
        _lastColor = nil
    }
}
