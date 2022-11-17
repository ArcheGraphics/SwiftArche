//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class Mesh {
    /// Name.
    public var name: String = ""
    /// The bounding volume of the mesh.
    public var bounds: BoundingBox = BoundingBox()

    var _instanceCount: Int = 1
    var _vertexBufferBindings: [MTLBuffer?] = []
    var _indexBufferBinding: IndexBufferBinding?
    var _vertexDescriptor = MTLVertexDescriptor()
    var _subMeshes: [SubMesh] = []
    var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()

    /// First sub-mesh. Rendered using the first material.
    public var subMesh: SubMesh? {
        get {
            _subMeshes.first
        }
    }

    /// A collection of sub-mesh, each sub-mesh can be rendered with an independent material.
    public var subMeshes: [SubMesh] {
        get {
            _subMeshes
        }
    }

    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameter subMesh: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    /// - Returns: Sub-mesh
    public func addSubMesh(_ subMesh: SubMesh) -> SubMesh {
        _subMeshes.append(subMesh)
        return subMesh
    }

    /// Add sub-mesh, each sub-mesh can correspond to an independent material.
    /// - Parameters:
    ///   - start: Start drawing offset, if the index buffer is set, it means the offset in the index buffer, if not set, it means the offset in the vertex buffer
    ///   - count: Drawing count, if the index buffer is set, it means the count in the index buffer, if not set, it means the count in the vertex buffer
    ///   - topology: Drawing topology, default is MeshTopology.Triangles
    /// - Returns: Sub-mesh
    public func addSubMesh(_ start: Int = 0, _ count: Int = 0, _ topology: MTLPrimitiveType = .triangle) -> SubMesh {
        let submesh = SubMesh(start, count, topology)
        _subMeshes.append(submesh)
        return submesh
    }

    ///
    /// Remove sub-mesh.
    /// - Parameter subMesh: Sub-mesh needs to be removed
    public func removeSubMesh(_ subMesh: SubMesh) {
        _subMeshes.removeAll { (v: SubMesh) in
            v === subMesh
        }
    }

    /// Clear all sub-mesh.
    public func clearSubMesh() {
        _subMeshes = []
    }

    func _setVertexBufferBinding(_ index: Int, _ binding: MTLBuffer) {
        _vertexBufferBindings[index] = binding
    }

    func _setIndexBufferBinding(_ binding: IndexBufferBinding?) {
        _indexBufferBinding = binding
    }

    private func _onBoundsChanged() {
        _updateFlagManager.dispatch(type: MeshModifyFlags.Bounds.rawValue)
    }
}

enum MeshModifyFlags: Int {
    case  Bounds = 0x1
    case  VertexElements = 0x2
}
