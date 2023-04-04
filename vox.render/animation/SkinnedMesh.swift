//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class SkinnedMesh: Mesh {
    private var _nativeSkin = CSkin()
    
    private var _destroyed = false
    private var _positions: [Float] = []
    private var _normals: [Float] = []
    private var _colors: [Float] = []
    private var _tangents: [Float] = []
    private var _uvs: [Float] = []
    private var _boneWeights: [Float] = []
    private var _boneIndices: [Float] = []
    private var _indices: [UInt16] = []
    private var _vertices: [Float] = []
    private var _elementCount: Int = 0
    var _meshes: [Mesh] = []

    public var skinCount: Int {
        Int(_nativeSkin.skinCount())
    }
    
    public func destroy() {
        if !_destroyed {
            _nativeSkin.destroy()
            _destroyed = true
        }
    }
    
    public override init() {
        super.init()
        _vertexDescriptor = _updateVertexDescriptor()
    }
    
    public func loadSkin(_ url: URL) {
        _nativeSkin.load(url.path(percentEncoded: false))
        _meshes = []
        for i in 0..<_nativeSkin.skinCount() {
            _uploadData(at: Int(i))
        }
    }
    
    public func vertexCount(at index: Int) -> Int {
        Int(_nativeSkin.vertexCount(at: UInt32(index)))
    }
    
    public func indicesCount(at index: Int) -> Int {
        Int(_nativeSkin.indicesCount(at: UInt32(index)))
    }
    
    public func skinningMatricesCount(at index: Int) -> Int {
        Int(_nativeSkin.skinningMatricesCount(at: UInt32(index)))
    }
    
    public func getSkinningMatrices(at index: Int, animator: Animator, matrix: inout [simd_float4x4]) {
        _nativeSkin.getSkinningMatrices(at: UInt32(index), animator._nativeAnimator, &matrix)
    }
    
    private func _uploadData(at index: Int) {
        let vertexCount = vertexCount(at: index)
        _positions = [Float](repeating: 0, count: 3 * vertexCount)
        _normals = [Float](repeating: 0, count: 3 * vertexCount)
        _colors = [Float](repeating: 0, count: 4 * vertexCount)
        _tangents = [Float](repeating: 0, count: 4 * vertexCount)
        _uvs = [Float](repeating: 0, count: 2 * vertexCount)
        _boneWeights = [Float](repeating: 0, count: 4 * vertexCount)
        _boneIndices = [Float](repeating: 0, count: 4 * vertexCount)
        _indices = [UInt16](repeating: 0, count: indicesCount(at: index))
        _nativeSkin.getMeshData(at: UInt32(index), &_positions, &_normals, &_tangents, &_uvs,
                                &_boneIndices, &_boneWeights, &_colors, &_indices)
        
        let vertexFloatCount = _elementCount * vertexCount
        if (_vertices.count != vertexFloatCount) {
            _vertices = [Float](repeating: 0, count: vertexFloatCount)
        }
        _updateVertices(&_vertices, with: vertexCount)
        
        let mesh = Mesh()
        mesh._vertexDescriptor = _vertexDescriptor
        mesh._setVertexBufferBinding(0, BufferView(array: _vertices))
        mesh._setIndexBufferBinding(IndexBufferBinding(BufferView(array: _indices), .uint16))
        mesh.addSubMesh(0, _indices.count, .triangle)
        _meshes.append(mesh)
    }
    
    private func _updateVertices(_ vertices: inout [Float], with vertexCount: Int) {
        // position
        for i in 0..<vertexCount {
            let start = _elementCount * i
            vertices[start] = _positions[i * 3]
            vertices[start + 1] = _positions[i * 3 + 1]
            vertices[start + 2] = _positions[i * 3 + 2]
        }
        var offset = 3
        
        // normal
        for i in 0..<vertexCount {
            let start = _elementCount * i + offset
            vertices[start] = _normals[3 * i]
            vertices[start + 1] = _normals[3 * i + 1]
            vertices[start + 2] = _normals[3 * i + 2]
        }
        offset += 3
        
        // color
        for i in 0..<vertexCount {
            let start = _elementCount * i + offset
            vertices[start] = _colors[4 * i]
            vertices[start + 1] = _colors[4 * i + 1]
            vertices[start + 2] = _colors[4 * i + 2]
            vertices[start + 3] = _colors[4 * i + 3]
            
        }
        offset += 4
        
        // boneWeight
        for i in 0..<vertexCount {
            let start = _elementCount * i + offset
            vertices[start] = _boneWeights[i * 4]
            vertices[start + 1] = _boneWeights[i * 4 + 1]
            vertices[start + 2] = _boneWeights[i * 4 + 2]
            vertices[start + 3] = _boneWeights[i * 4 + 3]
            
        }
        offset += 4
        
        // boneIndices
        for i in 0..<vertexCount {
            let start = _elementCount * i + offset
            vertices[start] = _boneIndices[i * 4]
            vertices[start + 1] = _boneIndices[i * 4 + 1]
            vertices[start + 2] = _boneIndices[i * 4 + 2]
            vertices[start + 3] = _boneIndices[i * 4 + 3]
            
        }
        offset += 4
        
        // tangent
        for i in 0..<vertexCount {
            let start = _elementCount * i + offset
            vertices[start] = _tangents[i * 4]
            vertices[start + 1] = _tangents[i * 4 + 1]
            vertices[start + 2] = _tangents[i * 4 + 2]
            vertices[start + 3] = _tangents[i * 4 + 3]
        }
        offset += 4
        
        // uvs
        for i in 0..<vertexCount {
            let start = _elementCount * i + offset
            vertices[start] = _uvs[i * 2]
            vertices[start + 1] = _uvs[i * 2 + 1]
        }
        offset += 2
    }
    
    private func _updateVertexDescriptor() -> MTLVertexDescriptor {
        // position
        let descriptor = MTLVertexDescriptor()
        var desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 0
        descriptor.attributes[Int(Position.rawValue)] = desc
        
        // normal
        var offset = 12
        var elementCount = 3
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = offset
        desc.bufferIndex = 0
        descriptor.attributes[Int(Normal.rawValue)] = desc
        offset += MemoryLayout<Float>.stride * 3
        elementCount += 3
        
        // color
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float4
        desc.offset = offset
        desc.bufferIndex = 0
        descriptor.attributes[Int(Color_0.rawValue)] = desc
        offset += MemoryLayout<Float>.stride * 4
        elementCount += 4
        
        // weight
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float4
        desc.offset = offset
        desc.bufferIndex = 0
        descriptor.attributes[Int(Weights_0.rawValue)] = desc
        offset += MemoryLayout<Float>.stride * 4
        elementCount += 4
        
        // joint
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float4
        desc.offset = offset
        desc.bufferIndex = 0
        descriptor.attributes[Int(Joints_0.rawValue)] = desc
        offset += MemoryLayout<Float>.stride * 4
        elementCount += 4
        
        // tangent
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float4
        desc.offset = offset
        desc.bufferIndex = 0
        descriptor.attributes[Int(Tangent.rawValue)] = desc
        offset += MemoryLayout<Float>.stride * 4
        elementCount += 4
        
        // uv
        desc = MTLVertexAttributeDescriptor()
        desc.format = .float2
        desc.offset = offset
        desc.bufferIndex = 0
        descriptor.attributes[Int(UV_0.rawValue)] = desc
        offset += MemoryLayout<Float>.stride * 2
        elementCount += 2
        
        _elementCount = elementCount
        descriptor.layouts[0].stride = offset
        return descriptor
    }
}
