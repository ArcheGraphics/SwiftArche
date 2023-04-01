//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class LineBatcher : Batcher {
    static var _ins: LineBatcher!
    var pointBuffer: BufferView!
    var colorBuffer: BufferView!
    
    var indirectPointBuffer: BufferView?
    var indirectColorBuffer: BufferView?
    var indirectIndicesBuffer: BufferView?
    var indicesCount: Int = 0
    
    var maxVerts: Int = 0
    var numVerts: Int = 0
    
    private let _shaderMacro = ShaderMacroCollection()
    private let _depthStencilDescriptor = MTLDepthStencilDescriptor()
    private let _pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var _pso: RenderPipelineState!
    private var _depthStencilState: MTLDepthStencilState!
    private var _material: Material!
    private let _descriptor = MTLVertexDescriptor()

    static var ins: LineBatcher {
        if _ins == nil {
            _ins = LineBatcher()
        }
        return _ins
    }
    
    var containData: Bool {
        numVerts != 0 || indicesCount > 0
    }
    
    func addLine(p0: Vector3, p1: Vector3, color: Color32) {
        checkResizePoint(count: numVerts + 2)
        addVert(p0, color32: color)
        addVert(p1, color32: color)
    }
    
    func addLine(p0: Vector3, p1: Vector3, color0: Color32, color1: Color32) {
        checkResizePoint(count: numVerts + 2)
        addVert(p0, color32: color0)
        addVert(p1, color32: color1)
    }
    
    func addLines(indicesCount: Int, positions: [Vector3], indices: [UInt32], colors: [Color32]) {
        self.indicesCount = indicesCount
        if indicesCount > 0 {
            if indirectPointBuffer?.count ?? 0 > positions.count {
                indirectPointBuffer!.assign(with: positions)
            } else {
                indirectPointBuffer = BufferView(device: Engine.device, array: positions)
            }
            
            if indirectIndicesBuffer?.count ?? 0 > indices.count {
                indirectIndicesBuffer!.assign(with: indices)
            } else {
                indirectIndicesBuffer = BufferView(device: Engine.device, array: indices)
            }
            
            if indirectColorBuffer?.count ?? 0 > colors.count {
                indirectColorBuffer!.assign(with: colors)
            } else {
                indirectColorBuffer = BufferView(device: Engine.device, array: colors)
            }
        }
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
    func prepare(_ encoder: MTLRenderCommandEncoder) {
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
        
        _material = BaseMaterial(shader: Shader.create(in: Engine.library(), vertexSource: "vertex_line_gizmos",
                                                       fragmentSource: "fragment_line_gizmos"))
        _pipelineDescriptor.label = "Line Gizmo Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            _pipelineDescriptor.stencilAttachmentPixelFormat = format
        }

        let functions = Engine.resourceCache.requestShaderModule(_material.shader.subShaders[0].passes[0], _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = _descriptor
        _material.renderStates[0]._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = Engine.resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = Engine.resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }
    
    func drawBatcher(_ encoder: inout RenderCommandEncoder, _ camera: Camera) {
        encoder.handle.pushDebugGroup("Line Gizmo Subpass")
        if (_pso == nil) {
            prepare(encoder.handle)
        }
        encoder.handle.setDepthStencilState(_depthStencilState)
        encoder.handle.setFrontFacing(.clockwise)
        encoder.handle.setCullMode(.back)
        encoder.bind(camera: camera, _pso)
        
        if let pointBuffer = pointBuffer,
           let colorBuffer = colorBuffer {
            encoder.handle.setVertexBuffer(pointBuffer.buffer, offset: 0, index: 0)
            encoder.handle.setVertexBuffer(colorBuffer.buffer, offset: 0, index: 1)
            encoder.handle.drawPrimitives(type: .line, vertexStart: 0,
                                          vertexCount: numVerts, instanceCount: 1)
        }
        
        if indicesCount > 0,
           let indirectPointBuffer,
           let indirectColorBuffer,
           let indirectIndicesBuffer {
            encoder.handle.setVertexBuffer(indirectPointBuffer.buffer, offset: 0, index: 0)
            encoder.handle.setVertexBuffer(indirectColorBuffer.buffer, offset: 0, index: 1)
            encoder.handle.drawIndexedPrimitives(type: .line, indexCount: indicesCount, indexType: .uint32,
                                                 indexBuffer: indirectIndicesBuffer.buffer, indexBufferOffset: 0)
        }
        encoder.handle.popDebugGroup()
        flush()
    }
    
    func flush() {
        numVerts = 0
        indicesCount = 0
    }
}
