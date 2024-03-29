//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public class ModelMesh: Mesh {
    var _blendShapeManager: BlendShapeManager!

    private var _elementCount: Int = 0
    private var _vertexCount: Int = 0
    private var _accessible: Bool = true
    private var _vertices: [Float]?
    private var _indices16: [UInt16]?
    private var _indices32: [UInt32]?
    private var _indicesFormat: MTLIndexType?
    private var _vertexSlotChanged: Bool = true
    private var _vertexChangeFlag: Int = 0
    private var _indicesChangeFlag: Bool = false
    private var _vertexStrideFloat: Float = 0
    private var _lastUploadVertexCount: Int = -1

    private var _positions: [Vector3] = []
    private var _normals: [Vector3]? = nil
    private var _colors: [Color]? = nil
    private var _tangents: [Vector4]? = nil
    private var _uv: [Vector2]? = nil
    private var _uv1: [Vector2]? = nil
    private var _uv2: [Vector2]? = nil
    private var _uv3: [Vector2]? = nil
    private var _uv4: [Vector2]? = nil
    private var _uv5: [Vector2]? = nil
    private var _uv6: [Vector2]? = nil
    private var _uv7: [Vector2]? = nil
    private var _boneWeights: [Vector4]? = nil
    private var _boneIndices: [Vector4]? = nil

    /// Whether to access data of the mesh.
    public var accessible: Bool {
        _accessible
    }

    /// Vertex count of current mesh.
    public var vertexCount: Int {
        _vertexCount
    }

    /// BlendShapes of this ModelMesh.
    public var blendShapes: [BlendShape] {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _blendShapeManager._blendShapes
    }

    /// BlendShape count of this ModelMesh.
    public var blendShapeCount: Int {
        _blendShapeManager._blendShapeCount
    }

    /// Create a model mesh.
    /// - Parameters:
    ///   - name: Mesh name
    public init(_ name: String = "") {
        super.init()
        self.name = name
        _blendShapeManager = BlendShapeManager(self)
    }
}

public extension ModelMesh {
    /// Set positions for the mesh.
    /// - Parameter positions: The positions for the mesh.
    func setPositions(positions: [Vector3]) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        _positions = positions
        _vertexCount = positions.count
        _vertexChangeFlag |= ValueChanged.Position.rawValue
    }

    /// Get positions for the mesh.
    /// - Remark: Please call the setPositions() method after modification to ensure that the modification takes effect.
    func getPositions() -> [Vector3]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        return _positions
    }

    /// Set per-vertex normals for the mesh.
    /// - Parameter normals: The normals for the mesh.
    func setNormals(normals: [Vector3]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if normals?.count != _vertexCount {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_normals != nil ? true : false) != (normals != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.Normal.rawValue
        _normals = normals
    }

    /// Get normals for the mesh.
    /// - Remark: Please call the setNormals() method after modification to ensure that the modification takes effect.
    func getNormals() -> [Vector3]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _normals
    }

    /// Set per-vertex colors for the mesh.
    /// - Parameter colors: The colors for the mesh.
    func setColors(colors: [Color]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if colors?.count != _vertexCount {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_colors != nil ? true : false) != (colors != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.Color.rawValue
        _colors = colors
    }

    /// Get colors for the mesh.
    /// - Remark: Please call the setColors() method after modification to ensure that the modification takes effect.
    func getColors() -> [Color]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _colors
    }

    /// Set per-vertex weights for the mesh.
    /// - Parameter boneWeights: The weights for the mesh.
    func setBoneWeights(boneWeights: [Vector4]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if boneWeights?.count != _vertexCount {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_tangents != nil ? true : false) != (boneWeights != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.BoneWeight.rawValue
        _boneWeights = boneWeights
    }

    /// Get weights for the mesh.
    /// - Remark: Please call the setBoneWeights() method after modification to ensure that the modification takes effect.
    func getBoneWeights() -> [Vector4]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _boneWeights
    }

    /// Set per-vertex joints for the mesh.
    /// - Parameter boneIndices: The joints for the mesh.
    func setBoneIndices(_ boneIndices: [Vector4]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if boneIndices?.count != _vertexCount {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_tangents != nil ? true : false) != (boneIndices != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.BoneIndex.rawValue
        _boneIndices = boneIndices
    }

    /// Get joints for the mesh.
    /// - Remark: Please call the setBoneIndices() method after modification to ensure that the modification takes effect.
    func getBoneIndices() -> [Vector4]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _boneIndices
    }

    /// Set per-vertex tangents for the mesh.
    /// - Parameter tangents: The tangents for the mesh.
    func setTangents(tangents: [Vector4]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if tangents?.count != _vertexCount {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        _vertexSlotChanged = (_tangents != nil ? true : false) != (tangents != nil ? true : false)
        _vertexChangeFlag |= ValueChanged.Tangent.rawValue
        _tangents = tangents
    }

    /// Get tangents for the mesh.
    /// - Remark: Please call the setTangents() method after modification to ensure that the modification takes effect.
    func getTangents() -> [Vector4]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _tangents
    }

    /// Set per-vertex uv for the mesh by channelIndex.
    /// - Parameters:
    ///   - uv: The uv for the mesh.
    ///   - channelIndex: The index of uv channels, in [0 ~ 7] range.
    func setUVs(uv: [Vector2]?, channelIndex: Int? = nil) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        if uv?.count != _vertexCount {
            fatalError("The array provided needs to be the same size as vertex count.")
        }

        let channelIndex = channelIndex ?? 0
        switch channelIndex {
        case 0:
            _vertexSlotChanged = (_uv != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV.rawValue
            _uv = uv
        case 1:
            _vertexSlotChanged = (_uv1 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV1.rawValue
            _uv1 = uv
        case 2:
            _vertexSlotChanged = (_uv2 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV2.rawValue
            _uv2 = uv
        case 3:
            _vertexSlotChanged = (_uv3 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV3.rawValue
            _uv3 = uv
        case 4:
            _vertexSlotChanged = (_uv4 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV4.rawValue
            _uv4 = uv
        case 5:
            _vertexSlotChanged = (_uv5 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV5.rawValue
            _uv5 = uv
        case 6:
            _vertexSlotChanged = (_uv6 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV6.rawValue
            _uv6 = uv
        case 7:
            _vertexSlotChanged = (_uv7 != nil ? true : false) != (uv != nil ? true : false)
            _vertexChangeFlag |= ValueChanged.UV7.rawValue
            _uv7 = uv
        default:
            fatalError("The index of channel needs to be in range [0 - 7].")
        }
    }

    /// Get uv for the mesh by channelIndex.
    /// - Parameter channelIndex: The index of uv channels, in [0 ~ 7] range.
    /// - Remark: Please call the setUV() method after modification to ensure that the modification takes effect.
    func getUVs(channelIndex: Int? = nil) -> [Vector2]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        let channelIndex = channelIndex ?? 0
        switch channelIndex {
        case 0:
            return _uv
        case 1:
            return _uv1
        case 2:
            return _uv2
        case 3:
            return _uv3
        case 4:
            return _uv4
        case 5:
            return _uv5
        case 6:
            return _uv6
        case 7:
            return _uv7
        default:
            fatalError("The index of channel needs to be in range [0 - 7].")
        }
    }

    /// Set indices for the mesh.
    /// - Parameter indices: The indices for the mesh.
    func setIndices(indices: [UInt16]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        _indices16 = indices
        _indicesFormat = .uint16
        _indicesChangeFlag = true
    }

    /// Set indices for the mesh.
    /// - Parameter indices: The indices for the mesh.
    func setIndices(indices: [UInt32]?) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        _indices32 = indices
        _indicesFormat = .uint32
        _indicesChangeFlag = true
    }

    /// Get indices for the mesh.
    func getIndices() -> [UInt16]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _indices16
    }

    /// Get indices for the mesh.
    func getIndices() -> [UInt32]? {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        return _indices32
    }

    /// Add a BlendShape for this ModelMesh.
    /// - Parameter blendShape: The BlendShape
    func addBlendShape(_ blendShape: BlendShape) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        _blendShapeManager._addBlendShape(blendShape)
    }

    /// Clear all BlendShapes.
    func clearBlendShapes() {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }
        _blendShapeManager._clearBlendShapes()
    }

    /// Get name of BlendShape by given index.
    /// - Parameter index: The index of BlendShape
    /// - Returns: The name of BlendShape
    func getBlendShapeName(at index: Int) -> String {
        if _accessible {
            let blendShapes = _blendShapeManager._blendShapes
            return blendShapes[index].name
        } else {
            return _blendShapeManager._blendShapeNames[index]
        }
    }

    /// Upload Mesh Data to the graphics API.
    /// - Parameter noLongerAccessible: Whether to access data later. If true, you'll never access data anymore (free memory cache)
    func uploadData(_ noLongerAccessible: Bool) {
        if !_accessible {
            fatalError("Not allowed to access data while accessible is false.")
        }

        // Vertex element change.
        if _vertexSlotChanged {
            _vertexDescriptor = _updateVertexDescriptor()
            _vertexChangeFlag = ValueChanged.All.rawValue
            _vertexSlotChanged = false
        }

        // Vertex value change.
        let vertexFloatCount = _elementCount * _vertexCount
        if _vertices?.count != vertexFloatCount {
            _vertices = [Float](repeating: 0, count: vertexFloatCount)
        }
        _vertexChangeFlag = ValueChanged.All.rawValue
        _updateVertices(vertices: &_vertices!)
        _setVertexBufferBinding(0, BufferView(array: _vertices!))

        if _indicesFormat == MTLIndexType.uint16 {
            _setIndexBufferBinding(IndexBufferBinding(BufferView(array: _indices16!), .uint16))
        } else if _indicesFormat == MTLIndexType.uint32 {
            _setIndexBufferBinding(IndexBufferBinding(BufferView(array: _indices32!), .uint32))
        }

        if _blendShapeManager._blendShapeCount > 0 {
            _blendShapeManager._update(true, noLongerAccessible)
        }

        if noLongerAccessible {
            _accessible = false
            _releaseCache()
        }
    }

    /// Calculate mesh tangent.
    /// - Remark: need to set positions(with or not with indices), normals, uv before calculation.
    /// - Remark: based on http://foundationsofgameenginedev.com/FGED2-sample.pdf
    internal func calculateTangents() {
        if let normals = _normals,
           let uv = _uv
        {
            let triangleCount = _indices32 != nil ? _indices32!.count / 3 : _positions.count / 3
            var tangents = [Vector4](repeating: Vector4(), count: vertexCount)
            var biTangents = [Vector3](repeating: Vector3(), count: vertexCount)
            // Calculate tangent and bi-tangent for each triangle and add to all three vertices.
            for k in 0 ..< triangleCount {
                var i0 = 3 * k
                var i1 = 3 * k + 1
                var i2 = 3 * k + 2
                if _indices32 != nil {
                    i0 = Int(_indices32![i0])
                    i1 = Int(_indices32![i1])
                    i2 = Int(_indices32![i2])
                }

                let p0 = _positions[i0]
                let p1 = _positions[i1]
                let p2 = _positions[i2]
                let w0 = uv[i0]
                let w1 = uv[i1]
                let w2 = uv[i2]
                let e1 = p1 - p0
                let e2 = p2 - p0
                let x1 = w1.x - w0.x
                let x2 = w2.x - w0.x
                let y1 = w1.y - w0.y
                let y2 = w2.y - w0.y
                let r = 1.0 / (x1 * y2 - x2 * y1)

                let t = e1 * y2 * r - e2 * y1 * r
                let b = e2 * x1 * r - e1 * x2 * r

                tangents[i0] += Vector4(t, 0.0)
                tangents[i1] += Vector4(t, 0.0)
                tangents[i2] += Vector4(t, 0.0)
                biTangents[i0] += b
                biTangents[i1] += b
                biTangents[i2] += b
            }

            // Orthonormalize each tangent and calculate the handedness.
            for i in 0 ..< vertexCount {
                let n = normals[i]
                let b = biTangents[i]
                let tangent = tangents[i]
                var t = Vector3(tangent.x, tangent.y, tangent.z)
                var temp = Vector3.cross(left: t, right: b)
                let w: Float = Vector3.dot(left: temp, right: n) > 0.0 ? 1 : -1
                temp = n * Vector3.dot(left: t, right: n)
                t -= temp
                tangents[i] = Vector4(t.normalized, w)
            }
            setTangents(tangents: tangents)
        } else {
            fatalError("Set normal and uv before calculation.")
        }
    }

    private func _updateVertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        var desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 0
        descriptor.attributes[Int(Position.rawValue)] = desc

        var offset = 12
        var elementCount = 3
        if _normals != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float3
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(Normal.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 3
            elementCount += 3
        }
        if _colors != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float4
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(Color_0.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 4
            elementCount += 4
        }
        if _boneWeights != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float4
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(Weights_0.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 4
            elementCount += 4
        }
        if _boneIndices != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float4
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(Joints_0.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 4
            elementCount += 4
        }
        if _tangents != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float4
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(Tangent.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 4
            elementCount += 4
        }
        if _uv != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_0.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv1 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_1.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv2 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_2.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv3 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_3.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv4 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_4.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv5 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_5.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv6 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_6.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        if _uv7 != nil {
            desc = MTLVertexAttributeDescriptor()
            desc.format = .float2
            desc.offset = offset
            desc.bufferIndex = 0
            descriptor.attributes[Int(UV_7.rawValue)] = desc
            offset += MemoryLayout<Float>.stride * 2
            elementCount += 2
        }
        descriptor.layouts[0].stride = offset

        _elementCount = elementCount
        return descriptor
    }

    private func _updateVertices(vertices: inout [Float]) {
        if _vertexChangeFlag & ValueChanged.Position.rawValue != 0 {
            for i in 0 ..< _vertexCount {
                let start = _elementCount * i
                let position = _positions[i]
                vertices[start] = position.x
                vertices[start + 1] = position.y
                vertices[start + 2] = position.z
            }
        }

        var offset = 3

        if _normals != nil {
            if _vertexChangeFlag & ValueChanged.Normal.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let normal = _normals![i]
                    vertices[start] = normal.x
                    vertices[start + 1] = normal.y
                    vertices[start + 2] = normal.z
                }
            }
            offset += 3
        }

        if _colors != nil {
            if _vertexChangeFlag & ValueChanged.Color.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let color = _colors![i]
                    vertices[start] = color.r
                    vertices[start + 1] = color.g
                    vertices[start + 2] = color.b
                    vertices[start + 3] = color.a
                }
            }
            offset += 4
        }

        if _boneWeights != nil {
            if _vertexChangeFlag & ValueChanged.BoneWeight.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let weight = _boneWeights![i]
                    vertices[start] = weight.x
                    vertices[start + 1] = weight.y
                    vertices[start + 2] = weight.z
                    vertices[start + 3] = weight.w
                }
            }
            offset += 4
        }

        if _boneIndices != nil {
            if _vertexChangeFlag & ValueChanged.BoneIndex.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let joints = _boneIndices![i]
                    vertices[start] = joints.x
                    vertices[start + 1] = joints.y
                    vertices[start + 2] = joints.z
                    vertices[start + 3] = joints.w
                }
            }
            offset += 4
        }

        if _tangents != nil {
            if _vertexChangeFlag & ValueChanged.Tangent.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let tangent = _tangents![i]
                    vertices[start] = tangent.x
                    vertices[start + 1] = tangent.y
                    vertices[start + 2] = tangent.z
                    vertices[start + 3] = tangent.w
                }
            }
            offset += 4
        }
        if _uv != nil {
            if _vertexChangeFlag & ValueChanged.UV.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv1 != nil {
            if _vertexChangeFlag & ValueChanged.UV1.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv1![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv2 != nil {
            if _vertexChangeFlag & ValueChanged.UV2.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv2![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv3 != nil {
            if _vertexChangeFlag & ValueChanged.UV3.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv3![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv4 != nil {
            if _vertexChangeFlag & ValueChanged.UV4.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv4![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv5 != nil {
            if _vertexChangeFlag & ValueChanged.UV5.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv5![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv6 != nil {
            if _vertexChangeFlag & ValueChanged.UV6.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv6![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }
        if _uv7 != nil {
            if _vertexChangeFlag & ValueChanged.UV7.rawValue != 0 {
                for i in 0 ..< _vertexCount {
                    let start = _elementCount * i + offset
                    let uv = _uv7![i]
                    vertices[start] = uv.x
                    vertices[start + 1] = uv.y
                }
            }
            offset += 2
        }

        _vertexChangeFlag = 0
    }

    private func _releaseCache() {
        _vertices = nil
        _positions = []
        _tangents = nil
        _normals = nil
        _colors = nil
        _uv = nil
        _uv1 = nil
        _uv2 = nil
        _uv3 = nil
        _uv4 = nil
        _uv5 = nil
        _uv6 = nil
        _uv7 = nil
        _blendShapeManager._releaseMemoryCache()
    }
}

enum ValueChanged: Int {
    case Position = 0x1
    case Normal = 0x2
    case Color = 0x4
    case Tangent = 0x8
    case BoneWeight = 0x10
    case BoneIndex = 0x20
    case UV = 0x40
    case UV1 = 0x80
    case UV2 = 0x100
    case UV3 = 0x200
    case UV4 = 0x400
    case UV5 = 0x800
    case UV6 = 0x1000
    case UV7 = 0x2000
    case BlendShape = 0x4000
    case All = 0xFFFF
}
