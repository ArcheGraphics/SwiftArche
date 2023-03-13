//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

class MeshParser: Parser {
    override func parse(_ context: ParserContext) {
        let glTFResource = context.glTFResource!
        let gltf = glTFResource.gltf!

        if gltf.meshes.isEmpty {
            return
        }

        var meshPromises: [[ModelMesh]] = []
        for i in 0..<gltf.meshes.count {
            if context.meshIndex != nil && context.meshIndex! != i {
                continue
            }
            let gltfMesh = gltf.meshes[i]
            var primitivePromises: [ModelMesh] = []
            for j in 0..<gltfMesh.primitives.count {
                if (context.subMeshIndex != nil && context.subMeshIndex! != j) {
                    continue
                }
                let gltfPrimitive = gltfMesh.primitives[j]
                let mesh = ModelMesh(glTFResource.engine, gltfMesh.name ?? "\(j)")
                primitivePromises.append(mesh)

                // load position
                var vertexCount: Int = 0
                var bufferFloat3: [Float] = []
                if let accessor: GLTFAccessor = gltfPrimitive.attributes["POSITION"] {
                    vertexCount = accessor.count
                    bufferFloat3 = [Float](repeating: 0, count: vertexCount * 3)
                    var position: [Vector3] = []
                    position.reserveCapacity(vertexCount)
                    GLTFUtil.convert(accessor, out: &bufferFloat3)
                    for i in 0..<vertexCount {
                        position.append(Vector3(bufferFloat3[i * 3], bufferFloat3[i * 3 + 1], bufferFloat3[i * 3 + 2]))
                    }
                    mesh.setPositions(positions: position)
                    
                    if accessor.minValues.count == 3 && accessor.maxValues.count == 3 {
                        mesh.bounds = BoundingBox(Vector3(
                                Float(truncating: accessor.minValues[0]),
                                Float(truncating: accessor.minValues[1]),
                                Float(truncating: accessor.minValues[2])
                        ), Vector3(Float(truncating: accessor.maxValues[0]),
                                Float(truncating: accessor.maxValues[1]),
                                Float(truncating: accessor.maxValues[2]))
                        )
                    } else {
                        var min = Vector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
                        var max = Vector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)
                        for j in 0..<vertexCount {
                            min = Vector3.min(left: min, right: position[j])
                            max = Vector3.max(left: max, right: position[j])
                        }
                        mesh.bounds = BoundingBox(min, max)
                    }
                }

                // load other attribute
                for accessor in gltfPrimitive.attributes {
                    if (accessor.key == "POSITION") {
                        continue
                    }
                    switch accessor.key {
                    case "NORMAL":
                        var normal: [Vector3] = []
                        normal.reserveCapacity(vertexCount)
                        GLTFUtil.convert(accessor.value, out: &bufferFloat3)
                        for i in 0..<vertexCount {
                            normal.append(Vector3(bufferFloat3[i * 3], bufferFloat3[i * 3 + 1], bufferFloat3[i * 3 + 2]))
                        }
                        mesh.setNormals(normals: normal)
                        break
                    case "TEXCOORD_0":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 0)
                        break
                    case "TEXCOORD_1":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 1)
                        break
                    case "TEXCOORD_2":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 2)
                        break
                    case "TEXCOORD_3":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 3)
                        break
                    case "TEXCOORD_4":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 4)
                        break
                    case "TEXCOORD_5":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 5)
                        break
                    case "TEXCOORD_6":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 6)
                        break
                    case "TEXCOORD_7":
                        var uv = [Vector2](repeating: Vector2(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &uv)
                        mesh.setUVs(uv: uv, channelIndex: 7)
                        break
                    case "COLOR_0":
                        if accessor.value.dimension == .vector3 {
                            GLTFUtil.convert(accessor.value, out: &bufferFloat3)
                            var color = [Color](repeating: Color(), count: vertexCount)
                            for i in 0..<vertexCount {
                                color[i] = Color(bufferFloat3[i * 3], bufferFloat3[i * 3 + 1], bufferFloat3[i * 3 + 2])
                            }
                            mesh.setColors(colors: color)
                        } else {
                            var color = [Color](repeating: Color(), count: vertexCount)
                            GLTFUtil.convert(accessor.value, out: &color)
                            mesh.setColors(colors: color)
                        }
                        break
                    case "TANGENT":
                        var tangent = [Vector4](repeating: Vector4(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &tangent)
                        mesh.setTangents(tangents: tangent)
                        break
                    case "JOINTS_0":
                        var joint = [Vector4](repeating: Vector4(), count: vertexCount)
                        let bytesPerComponent = GLTFBytesPerComponentForComponentType(accessor.value.componentType)
                        if bytesPerComponent == 2 {
                            var uint16Buffer = [UInt16](repeating: 0, count: vertexCount * 4)
                            GLTFUtil.convert(accessor.value, out: &uint16Buffer)
                            for i in 0..<vertexCount {
                                joint[i] = Vector4(Float(uint16Buffer[i * 4]), Float(uint16Buffer[i * 4 + 1]),
                                                   Float(uint16Buffer[i * 4 + 2]), Float(uint16Buffer[i * 4 + 3]))
                            }
                        } else if bytesPerComponent == 1 {
                            var uint8Buffer = [UInt8](repeating: 0, count: vertexCount * 4)
                            GLTFUtil.convert(accessor.value, out: &uint8Buffer)
                            for i in 0..<vertexCount {
                                joint[i] = Vector4(Float(uint8Buffer[i * 4]), Float(uint8Buffer[i * 4 + 1]),
                                                   Float(uint8Buffer[i * 4 + 2]), Float(uint8Buffer[i * 4 + 3]))
                            }
                        }
                        mesh.setBoneIndices(joint)
                        break
                    case "WEIGHTS_0":
                        var weight = [Vector4](repeating: Vector4(), count: vertexCount)
                        GLTFUtil.convert(accessor.value, out: &weight)
                        mesh.setBoneWeights(boneWeights: weight)
                        break
                    default:
                        break
                    }
                }

                // load submesh
                var mode: MTLPrimitiveType = .triangle
                switch gltfPrimitive.primitiveType {
                case .lineLoop:
                    mode = .lineStrip
                    break
                case .lineStrip:
                    mode = .lineStrip
                    break
                case .lines:
                    mode = .line
                    break
                case .points:
                    mode = .point
                    break
                case .triangles:
                    mode = .triangle
                    break
                case .triangleFan:
                    mode = .triangleStrip
                    break
                case .triangleStrip:
                    mode = .triangleStrip
                    break
                default:
                    break
                }

                // load indices
                if let indexAccessor = gltfPrimitive.indices {
                    if indexAccessor.componentType == .unsignedShort {
                        var indices = [UInt16](repeating: 0, count: indexAccessor.count)
                        GLTFUtil.convert(indexAccessor, out: &indices)
                        mesh.setIndices(indices: indices)
                    } else if indexAccessor.componentType == .unsignedInt {
                        var indices = [UInt32](repeating: 0, count: indexAccessor.count)
                        GLTFUtil.convert(indexAccessor, out: &indices)
                        mesh.setIndices(indices: indices)
                    } else if indexAccessor.componentType == .unsignedByte {
                        var indicesBuffer = [UInt8](repeating: 0, count: indexAccessor.count)
                        GLTFUtil.convert(indexAccessor, out: &indicesBuffer)
                        mesh.setIndices(indices: indicesBuffer.map { value in
                            UInt16(value)
                        })
                    }
                    _ = mesh.addSubMesh(0, indexAccessor.count, mode)
                } else {
                    _ = mesh.addSubMesh(0, vertexCount, mode)
                }

                // load morph target
                if !gltfPrimitive.targets.isEmpty {
                    for j in 0..<gltfPrimitive.targets.count {
                        let target = gltfPrimitive.targets[j]
                        let deltaPosAccessor = target["POSITION"]
                        let deltaNorAccessor = target["NORMAL"]
                        let deltaTanAccessor = target["TANGENT"]
                        var deltaPositions: [Vector3]? = nil
                        var deltaNormals: [Vector3]? = nil
                        var deltaTangents: [Vector3]? = nil

                        var floatBuffer: [Float] = []
                        if let deltaPosAccessor = deltaPosAccessor {
                            floatBuffer = [Float](repeating: 0, count: deltaPosAccessor.count * 3)
                            GLTFUtil.convert(deltaPosAccessor, out: &floatBuffer)
                            
                            deltaPositions = []
                            deltaPositions!.reserveCapacity(vertexCount)
                            for i in 0..<vertexCount {
                                deltaPositions!.append(Vector3(floatBuffer[i * 3], floatBuffer[i * 3 + 1], floatBuffer[i * 3 + 2]))
                            }
                        }
                        if let deltaNorAccessor = deltaNorAccessor {
                            GLTFUtil.convert(deltaNorAccessor, out: &floatBuffer)
                            
                            deltaNormals = []
                            deltaNormals!.reserveCapacity(vertexCount)
                            for i in 0..<vertexCount {
                                deltaNormals!.append(Vector3(floatBuffer[i * 3], floatBuffer[i * 3 + 1], floatBuffer[i * 3 + 2]))
                            }
                        }
                        if let deltaTanAccessor = deltaTanAccessor {
                            GLTFUtil.convert(deltaTanAccessor, out: &floatBuffer)
                            
                            deltaTangents = []
                            deltaTangents!.reserveCapacity(vertexCount)
                            for i in 0..<vertexCount {
                                deltaTangents!.append(Vector3(floatBuffer[i * 3], floatBuffer[i * 3 + 1], floatBuffer[i * 3 + 2]))
                            }
                        }

                        let blendShape = BlendShape("blendShape\(j)")
                        _ = blendShape.addFrame(weight: 1.0, deltaPositions: deltaPositions!,
                                deltaNormals: deltaNormals, deltaTangents: deltaTangents)
                        mesh.addBlendShape(blendShape)
                    }
                }
                mesh.uploadData(!context.keepMeshData)
            }
            meshPromises.append(primitivePromises)
        }
        glTFResource.meshes = meshPromises
    }
}
