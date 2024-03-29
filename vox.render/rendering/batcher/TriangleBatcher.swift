//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class TriangleBatcher: Batcher {
    static var _ins: TriangleBatcher!
    var pointBuffer: BufferView!
    var colorBuffer: BufferView!
    var normalBuffer: BufferView!
    var maxVerts: Int = 0
    var numVerts: Int = 0
    var camera: Camera?

    private let _shaderMacro = ShaderMacroCollection()
    private let _depthStencilDescriptor = MTLDepthStencilDescriptor()
    private let _pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var _pso: RenderPipelineState!
    private var _depthStencilState: MTLDepthStencilState!
    private var _material: Material!
    private let _descriptor = MTLVertexDescriptor()

    static var ins: TriangleBatcher {
        if _ins == nil {
            _ins = TriangleBatcher()
        }
        return _ins
    }

    var containData: Bool {
        numVerts != 0
    }

    func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3,
                     n0: Vector3, n1: Vector3, n2: Vector3,
                     color: Color32)
    {
        checkResizePoint(count: numVerts + 3)
        addVert(p0, n: n0, color32: color)
        addVert(p1, n: n1, color32: color)
        addVert(p2, n: n2, color32: color)
    }

    func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3,
                     n0: Vector3, n1: Vector3, n2: Vector3,
                     color0: Color32, color1: Color32, color2: Color32)
    {
        checkResizePoint(count: numVerts + 3)
        addVert(p0, n: n0, color32: color0)
        addVert(p1, n: n1, color32: color1)
        addVert(p2, n: n2, color32: color2)
    }

    func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3, color: Color32) {
        checkResizePoint(count: numVerts + 3)
        let normal = Vector3.cross(left: p1 - p0, right: p2 - p0).normalized
        addVert(p0, n: normal, color32: color)
        addVert(p1, n: normal, color32: color)
        addVert(p2, n: normal, color32: color)
    }

    func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3,
                     color0: Color32, color1: Color32, color2: Color32)
    {
        checkResizePoint(count: numVerts + 3)
        let normal = Vector3.cross(left: p1 - p0, right: p2 - p0).normalized
        addVert(p0, n: normal, color32: color0)
        addVert(p1, n: normal, color32: color1)
        addVert(p2, n: normal, color32: color2)
    }

    func checkResizePoint(count: Int) {
        if count > maxVerts {
            maxVerts = Int(ceil(Float(count) * 1.2))
            let newPointBuffer = BufferView(count: maxVerts, stride: MemoryLayout<Vector3>.stride,
                                            label: "point buffer", options: .storageModeShared)
            let newColorBuffer = BufferView(count: maxVerts, stride: MemoryLayout<Color32>.stride,
                                            label: "color32 buffer", options: .storageModeShared)
            let newNormalBuffer = BufferView(count: maxVerts, stride: MemoryLayout<Vector3>.stride,
                                             label: "normal buffer", options: .storageModeShared)
            if let pointBuffer = pointBuffer,
               let colorBuffer = colorBuffer,
               let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
               let blit = commandBuffer.makeBlitCommandEncoder()
            {
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
           let normalBuffer = normalBuffer
        {
            pointBuffer.assign(p0, at: numVerts)
            colorBuffer.assign(color32, at: numVerts)
            normalBuffer.assign(n, at: numVerts)
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

        desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 2
        _descriptor.attributes[Int(Normal.rawValue)] = desc
        _descriptor.layouts[2].stride = MemoryLayout<Vector3>.stride

        _material = Material()
        _material.shader = Shader.create(in: Engine.library(), vertexSource: "vertex_triangle_gizmos",
                                         fragmentSource: "fragment_triangle_gizmos")
        _pipelineDescriptor.label = "Triangle Gizmo Pipeline"
        _pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        _pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat {
            _pipelineDescriptor.stencilAttachmentPixelFormat = format
        }

        let functions = Engine.resourceCache.requestShaderModule(_material.shader!.subShaders[0].passes[0], _shaderMacro)
        _pipelineDescriptor.vertexFunction = functions[0]
        _pipelineDescriptor.fragmentFunction = functions[1]
        _pipelineDescriptor.vertexDescriptor = _descriptor
        _material.renderStates[0]._apply(_pipelineDescriptor, _depthStencilDescriptor, encoder, false)

        _pso = Engine.resourceCache.requestGraphicsPipeline(_pipelineDescriptor)
        _depthStencilState = Engine.resourceCache.requestDepthStencilState(_depthStencilDescriptor)
    }

    func drawBatcher(_ encoder: inout RenderCommandEncoder, _ camera: Camera) {
        if let pointBuffer = pointBuffer,
           let colorBuffer = colorBuffer
        {
            encoder.handle.pushDebugGroup("Triangle Gizmo Subpass")
            if _pso == nil {
                prepare(encoder.handle)
            }

            encoder.handle.setDepthStencilState(_depthStencilState)
            encoder.handle.setFrontFacing(.clockwise)
            encoder.handle.setCullMode(.none)

            encoder.bind(camera: camera, _pso)

            encoder.handle.setVertexBuffer(pointBuffer.buffer, offset: 0, index: 0)
            encoder.handle.setVertexBuffer(colorBuffer.buffer, offset: 0, index: 1)
            encoder.handle.setVertexBuffer(normalBuffer.buffer, offset: 0, index: 2)
            encoder.handle.drawPrimitives(type: .triangle, vertexStart: 0,
                                          vertexCount: numVerts, instanceCount: 1)
            encoder.handle.popDebugGroup()
            flush()
        }
    }

    func flush() {
        numVerts = 0
    }
}
