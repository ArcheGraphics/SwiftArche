//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class PointBatcher : Batcher {
    static var _ins: PointBatcher!
    var pointBuffer: BufferView!
    var colorBuffer: BufferView!
    var maxVerts: Int = 0
    var numVerts: Int = 0
    
    private let _shaderMacro = ShaderMacroCollection()
    private let _depthStencilDescriptor = MTLDepthStencilDescriptor()
    private let _pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var _pso: RenderPipelineState!
    private var _depthStencilState: MTLDepthStencilState!
    private var _shaderPass: ShaderPass!
    private let _descriptor = MTLVertexDescriptor()

    static var ins: PointBatcher {
        if _ins == nil {
            _ins = PointBatcher()
        }
        return _ins
    }
    
    var containData: Bool {
        numVerts != 0
    }
    
    var pointSize: Float = 10
    
    func addPoint(_ p0: Vector3, color: Color32) {
        checkResizePoint(count: numVerts + 1)
        addVert(p0, color32: color)
    }
    
    func checkResizePoint(count: Int) {
        if count > maxVerts {
            maxVerts = Int(ceil(Float(count) * 1.2))
            let newPointBuffer = BufferView(device: Engine.device, count: maxVerts, stride: MemoryLayout<Vector3>.stride,
                                            label: "point buffer", options: .storageModeShared)
            let newColorBuffer = BufferView(device: Engine.device, count: maxVerts, stride: MemoryLayout<Color32>.stride,
                                            label: "color32 buffer", options: .storageModeShared)
            if let pointBuffer = pointBuffer,
               let colorBuffer = colorBuffer,
               let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
               let blit = commandBuffer.makeBlitCommandEncoder() {
                blit.copy(from: pointBuffer.buffer, sourceOffset: 0, to: newPointBuffer.buffer,
                          destinationOffset: 0, size: pointBuffer.count * pointBuffer.stride)
                blit.copy(from: colorBuffer.buffer, sourceOffset: 0, to: newColorBuffer.buffer,
                          destinationOffset: 0, size: colorBuffer.count * colorBuffer.stride)
                blit.endEncoding()
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()
            }
            pointBuffer = newPointBuffer
            colorBuffer = newColorBuffer
        }
    }
    
    func addVert(_ p0: Vector3, color32: Color32) {
        if maxVerts > numVerts,
           let pointBuffer = pointBuffer,
           let colorBuffer = colorBuffer {
            pointBuffer.assign(p0, at: numVerts)
            colorBuffer.assign(color32, at: numVerts)
            numVerts += 1
        }
    }
    
    // MARK: - Render
    func prepare(_ encoder: MTLRenderCommandEncoder, _ cache: ResourceCache) {
        var desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 0
        _descriptor.attributes[Int(Position.rawValue)] = desc
        _descriptor.layouts[0].stride = MemoryLayout<Vector3>.stride

        desc = MTLVertexAttributeDescriptor()
        desc.format = .uchar4
        desc.offset = 0
        desc.bufferIndex = 1
        _descriptor.attributes[Int(Color_0.rawValue)] = desc
        _descriptor.layouts[1].stride = MemoryLayout<Color32>.stride
        
        _shaderPass = ShaderPass(Engine.library(), "vertex_point_gizmos", "fragment_point_gizmos")

        _pipelineDescriptor.label = "Point Gizmo Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            _pipelineDescriptor.stencilAttachmentPixelFormat = format
        }

        let functions = cache.requestShaderModule(_shaderPass, _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = _descriptor
        _shaderPass.renderState!._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = cache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = cache.requestDepthStencilState(_depthStencilDescriptor)
    }
    
    func drawBatcher(_ encoder: inout RenderCommandEncoder, _ camera: Camera, _ cache: ResourceCache) {
        if let pointBuffer = pointBuffer,
           let colorBuffer = colorBuffer {
            encoder.handle.pushDebugGroup("Point Gizmo Subpass")
            if (_pso == nil) {
                prepare(encoder.handle, cache)
            }
            
            encoder.handle.setDepthStencilState(_depthStencilState)
            encoder.handle.setFrontFacing(.clockwise)
            encoder.handle.setCullMode(.back)
            
            encoder.bind(camera: camera, _pso, cache)
            
            encoder.handle.setVertexBuffer(pointBuffer.buffer, offset: 0, index: 0)
            encoder.handle.setVertexBuffer(colorBuffer.buffer, offset: 0, index: 1)
            encoder.handle.setVertexBytes(&pointSize, length: MemoryLayout<Float>.stride, index: 3)
            encoder.handle.drawPrimitives(type: .point, vertexStart: 0,
                                          vertexCount: numVerts, instanceCount: 1)
            encoder.handle.popDebugGroup()
            flush()
        }
    }
    
    func flush() {
        numVerts = 0
    }
}
