//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class TriangleSubpass : Subpass {
    static var _ins: TriangleSubpass!
    var pointBuffer: BufferView!
    var colorBuffer: BufferView!
    var normalBuffer: BufferView!
    var maxVerts: Int = 0
    var numVerts: Int = 0
    var engine: Engine!
    var camera: Camera?
    
    private var _resourceCache: ResourceCache!
    private let _shaderMacro = ShaderMacroCollection()
    private let _depthStencilDescriptor = MTLDepthStencilDescriptor()
    private let _pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var _pso: RenderPipelineState!
    private var _depthStencilState: MTLDepthStencilState!
    private var _shaderPass: ShaderPass!
    private let _descriptor = MTLVertexDescriptor()

    static var ins: TriangleSubpass {
        if _ins == nil {
            _ins = TriangleSubpass()
        }
        return _ins
    }
    
    var containData: Bool {
        numVerts != 0
    }
        
    func set(_ engine: Engine) {
        self.engine = engine
        _resourceCache = ResourceCache(engine.device)
    }
    
    func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3,
                     n0: Vector3, n1: Vector3, n2: Vector3,
                     color: Color32) {
        checkResizePoint(count: numVerts + 3)
        addVert(p0, n: n0, color32: color)
        addVert(p1, n: n1, color32: color)
        addVert(p2, n: n2, color32: color)
    }
    
    func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3, color: Color32) {
        checkResizePoint(count: numVerts + 3)
        let normal = Vector3.cross(left: p1 - p0, right: p2 - p0)
        addVert(p0, n: normal.normalized(), color32: color)
        addVert(p1, n: normal.normalized(), color32: color)
        addVert(p2, n: normal.normalized(), color32: color)
    }
    
    func checkResizePoint(count: Int) {
        if count > maxVerts {
            maxVerts = Int(ceil(Float(count) * 1.2))
            let newPointBuffer = BufferView(device: engine.device, count: maxVerts, stride: MemoryLayout<Vector3>.stride,
                                            label: "point buffer", options: .storageModeShared)
            let newColorBuffer = BufferView(device: engine.device, count: maxVerts, stride: MemoryLayout<Color32>.stride,
                                            label: "color32 buffer", options: .storageModeShared)
            let newNormalBuffer = BufferView(device: engine.device, count: maxVerts, stride: MemoryLayout<Vector3>.stride,
                                            label: "normal buffer", options: .storageModeShared)
            if let pointBuffer = pointBuffer,
               let colorBuffer = colorBuffer,
               let commandBuffer = engine.commandQueue.makeCommandBuffer(),
               let blit = commandBuffer.makeBlitCommandEncoder() {
                blit.copy(from: pointBuffer.buffer, sourceOffset: 0, to: newPointBuffer.buffer,
                          destinationOffset: 0, size: pointBuffer.count * pointBuffer.stride)
                blit.copy(from: colorBuffer.buffer, sourceOffset: 0, to: newColorBuffer.buffer,
                          destinationOffset: 0, size: colorBuffer.count * colorBuffer.stride)
                blit.copy(from: normalBuffer.buffer, sourceOffset: 0, to: newNormalBuffer.buffer,
                          destinationOffset: 0, size: normalBuffer.count * normalBuffer.stride)
                blit.endEncoding()
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()
            }
            pointBuffer = newPointBuffer
            colorBuffer = newColorBuffer
            normalBuffer = newNormalBuffer
        }
    }
    
    func addVert(_ p0: Vector3, n: Vector3, color32: Color32) {
        if maxVerts > numVerts,
           let pointBuffer = pointBuffer,
           let colorBuffer = colorBuffer,
           let normalBuffer = normalBuffer {
            pointBuffer.assign(p0, at: numVerts)
            colorBuffer.assign(color32, at: numVerts)
            normalBuffer.assign(n, at: numVerts)
            numVerts += 1
        }
    }
    
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
        
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 2
        _descriptor.attributes[Int(Normal.rawValue)] = desc
        _descriptor.layouts[2].stride = MemoryLayout<Vector3>.stride
        
        _shaderPass = ShaderPass(engine.library(), "vertex_triangle_gizmos", "fragment_triangle_gizmos")

        _pipelineDescriptor.label = "Triangle Gizmo Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            _pipelineDescriptor.stencilAttachmentPixelFormat = format
        }

        let functions = _resourceCache.requestShaderModule(_shaderPass, _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = _descriptor
        _shaderPass.renderState!._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = _resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = _resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }
    
    override func draw(_ encoder: inout RenderCommandEncoder) {
        if camera == nil {
            camera = Camera.mainCamera
        }
        guard let camera = camera else {
            fatalError("without enabled camera")
        }
        
        if let pointBuffer = pointBuffer,
           let colorBuffer = colorBuffer {
            encoder.handle.pushDebugGroup("Triangle Gizmo Subpass")
            if (_pso == nil) {
                prepare(encoder.handle)
            }
            
            encoder.handle.setDepthStencilState(_depthStencilState)
            encoder.handle.setFrontFacing(.clockwise)
            encoder.handle.setCullMode(.none)
            
            encoder.bind(camera: camera, _pso, _resourceCache)
            
            encoder.handle.setVertexBuffer(pointBuffer.buffer, offset: 0, index: 0)
            encoder.handle.setVertexBuffer(colorBuffer.buffer, offset: 0, index: 1)
            encoder.handle.setVertexBuffer(normalBuffer.buffer, offset: 0, index: 2)
            encoder.handle.drawPrimitives(type: .triangle, vertexStart: 0,
                                          vertexCount: numVerts, instanceCount: 1)
            encoder.handle.popDebugGroup()
            // flush
            numVerts = 0
        }
    }
}
