//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ModelIO

// MARK: - MDLVertexDescriptor

extension MDLVertexDescriptor {
    /// Returns the vertex buffer attribute descriptor at the specified index.
    func attribute(_ index: UInt32) -> MDLVertexAttribute {
        guard let attributes = attributes as? [MDLVertexAttribute] else { fatalError() }
        return attributes[Int(index)]
    }

    /// Returns the vertex buffer layout descriptor at the specified index.
    func layout(_ index: UInt32) -> MDLVertexBufferLayout {
        guard let layouts = layouts as? [MDLVertexBufferLayout] else { fatalError() }
        return layouts[Int(index)]
    }

    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0

        // MARK: - position attribute

        vertexDescriptor.attributes[Int(Position.rawValue)]
            = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                 format: .float3,
                                 offset: 0,
                                 bufferIndex: 0)
        offset += MemoryLayout<SIMD3<Float>>.stride

        // MARK: - normal attribute

        vertexDescriptor.attributes[Int(Normal.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeNormal,
                               format: .float3,
                               offset: offset,
                               bufferIndex: 0)
        offset += MemoryLayout<SIMD3<Float>>.stride

        // tangent attribute
        vertexDescriptor.attributes[Int(Tangent.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeTangent,
                               format: .float4,
                               offset: offset,
                               bufferIndex: 0)
        offset += MemoryLayout<SIMD4<Float>>.stride

        // MARK: - add the uv attribute here

        vertexDescriptor.attributes[Int(UV_0.rawValue)] =
            MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                               format: .float2,
                               offset: offset,
                               bufferIndex: 0)
        offset += MemoryLayout<SIMD2<Float>>.stride

        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor

    }()
}
