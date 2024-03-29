//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public class BlendShapeManager {
    private static let _blendShapeWeightsProperty = "u_blendShapeWeights"
    private static let _blendShapeTextureProperty = "u_blendShapeTexture"
    private static let _blendShapeSamplerProperty = "u_blendShapeSampler"
    private static let _blendShapeTextureInfoProperty = "u_blendShapeTextureInfo"
    private static let _blendSamplerDesc = MTLSamplerDescriptor()

    var _blendShapeCount: Int = 0
    var _blendShapes: [BlendShape] = []
    var _blendShapeNames: [String] = []
    var _subDataDirtyFlags: [BoolUpdateFlag] = []
    var _listenerFlags: [ListenerUpdateFlag] = []
    var _vertexTexture: MTLTexture!
    var _vertices: [Float] = []
    let maxTextureSize = 4096

    private var _useBlendNormal: Bool = false
    private var _useBlendTangent: Bool = false
    private var _vertexElementCount: Int = 0
    private var _vertexElementOffset: Int = 0
    private var _storeInVertexBufferInfo: [Vector2] = []
    private var _modelMesh: ModelMesh
    private var _lastCreateHostInfo: Vector3 = .init(0, 0, 0)
    private var _dataTextureInfo: SIMD3<UInt32> = .init()

    init(_ modelMesh: ModelMesh) {
        _modelMesh = modelMesh
        BlendShapeManager._blendSamplerDesc.mipFilter = .nearest
        BlendShapeManager._blendSamplerDesc.magFilter = .nearest
        BlendShapeManager._blendSamplerDesc.mipFilter = .nearest
    }

    func _addBlendShape(_ blendShape: BlendShape) {
        _blendShapes.append(blendShape)
        _blendShapeCount += 1

        let flag = ListenerUpdateFlag()
        flag.listener = _updateLayoutChange
        blendShape._layoutChangeManager.addFlag(flag: flag)
        _listenerFlags.append(flag)
        _updateLayoutChange(nil, blendShape)

        _subDataDirtyFlags.append(blendShape._createSubDataDirtyFlag())
    }

    func _clearBlendShapes() {
        _useBlendNormal = false
        _useBlendTangent = false
        _vertexElementCount = 0
        _blendShapes = []
        _blendShapeCount = 0
        _subDataDirtyFlags = []
        _listenerFlags = []
    }

    func _updateShaderData(_ shaderData: ShaderData, _ skinnedMeshRenderer: SkinnedMeshRenderer) {
        if _blendShapeCount > 0 {
            shaderData.enableMacro(HAS_BLENDSHAPE.rawValue)
            shaderData.setImageSampler(with: BlendShapeManager._blendShapeTextureProperty,
                                       BlendShapeManager._blendShapeSamplerProperty, texture: _vertexTexture)
            shaderData.setSampler(with: BlendShapeManager._blendShapeSamplerProperty, sampler: BlendShapeManager._blendSamplerDesc)
            shaderData.setData(with: BlendShapeManager._blendShapeTextureInfoProperty, data: _dataTextureInfo)
            shaderData.setData(with: BlendShapeManager._blendShapeWeightsProperty, array: skinnedMeshRenderer.blendShapeWeights)
            shaderData.enableMacro(BLENDSHAPE_COUNT.rawValue, (_blendShapeCount, .int))

            if _useBlendNormal {
                shaderData.enableMacro(HAS_BLENDSHAPE_NORMAL.rawValue)
            } else {
                shaderData.disableMacro(HAS_BLENDSHAPE_NORMAL.rawValue)
            }
            if _useBlendTangent {
                shaderData.enableMacro(HAS_BLENDSHAPE_TANGENT.rawValue)
            } else {
                shaderData.disableMacro(HAS_BLENDSHAPE_TANGENT.rawValue)
            }
        } else {
            shaderData.disableMacro(HAS_BLENDSHAPE.rawValue)
            shaderData.disableMacro(BLENDSHAPE_COUNT.rawValue)
        }
    }

    func _layoutOrCountChange() -> Bool {
        Int(_lastCreateHostInfo.x) != _blendShapeCount ||
            (_lastCreateHostInfo.y != 0) != _useBlendNormal ||
            (_lastCreateHostInfo.z != 0) != _useBlendTangent
    }

    func _needUpdateData() -> Bool {
        for subDataDirtyFlag in _subDataDirtyFlags {
            if subDataDirtyFlag.flag {
                return true
            }
        }
        return false
    }

    func _update(_ vertexCountChange: Bool, _: Bool) {
        let createHost = _layoutOrCountChange() || vertexCountChange
        if createHost {
            _createTextureArray(_modelMesh.vertexCount)
            _lastCreateHostInfo = Vector3(Float(_blendShapeCount), _useBlendNormal ? 1.0 : 0.0, _useBlendTangent ? 1.0 : 0.0)
        }
        if _needUpdateData() {
            _updateTextureArray(_modelMesh.vertexCount, createHost)
        }
    }

    func _releaseMemoryCache() {
        var blendShapeNamesMap = [String](repeating: "", count: _blendShapes.count)
        for i in 0 ..< _blendShapes.count {
            blendShapeNamesMap[i] = _blendShapes[i].name
        }
        _blendShapeNames = blendShapeNamesMap

        _listenerFlags = []
        _subDataDirtyFlags = []
        _blendShapes = []
    }

    private func _createTextureArray(_ vertexCount: Int) {
        var textureWidth = _vertexElementCount * vertexCount
        var textureHeight = 1
        if textureWidth > maxTextureSize {
            textureHeight = Int(ceil(Float(textureWidth) / Float(maxTextureSize)))
            textureWidth = maxTextureSize
        }

        let blendShapeCount = _blendShapes.count
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2DArray
        descriptor.width = textureWidth
        descriptor.height = textureHeight
        descriptor.arrayLength = blendShapeCount
        descriptor.pixelFormat = .rgba32Float
        descriptor.mipmapLevelCount = 1
        _vertexTexture = Engine.device.makeTexture(descriptor: descriptor)

        _vertices = [Float](repeating: 0, count: textureWidth * textureHeight * 4)
        _dataTextureInfo.x = UInt32(_vertexElementCount)
        _dataTextureInfo.y = UInt32(textureWidth)
        _dataTextureInfo.z = UInt32(textureHeight)
    }

    private func _updateTextureArray(_ vertexCount: Int, _ force: Bool) {
        for i in 0 ..< _blendShapes.count {
            let subDirtyFlag = _subDataDirtyFlags[i]
            if force || subDirtyFlag.flag {
                let frames = _blendShapes[i].frames
                if let endFrame = frames.last,
                   endFrame.deltaPositions.count == vertexCount
                {
                    var offset = 0
                    for j in 0 ..< vertexCount {
                        let position = endFrame.deltaPositions[j]
                        _vertices[offset] = position.x
                        _vertices[offset + 1] = position.y
                        _vertices[offset + 2] = position.z
                        offset += 4

                        if endFrame.deltaNormals != nil {
                            let normal = endFrame.deltaNormals![j]
                            _vertices[offset] = normal.x
                            _vertices[offset + 1] = normal.y
                            _vertices[offset + 2] = normal.z
                            offset += 4
                        }

                        if endFrame.deltaTangents != nil {
                            let tangent = endFrame.deltaTangents![j]
                            _vertices[offset] = tangent.x
                            _vertices[offset + 1] = tangent.y
                            _vertices[offset + 2] = tangent.z
                            offset += 4
                        }
                    }
                    _vertexTexture.replace(region: MTLRegionMake2D(0, 0, _vertexTexture.width, _vertexTexture.height),
                                           mipmapLevel: 0, slice: i, withBytes: &_vertices,
                                           bytesPerRow: _vertexTexture.width * 4 * MemoryLayout<Float>.stride,
                                           bytesPerImage: _vertices.count * MemoryLayout<Float>.stride)
                    subDirtyFlag.flag = false
                } else {
                    fatalError("BlendShape frame deltaPositions length must same with mesh vertexCount.")
                }
            }
        }
    }

    private func _updateLayoutChange(_: Int?, _ blendShape: AnyObject?) {
        let notFirst = _blendShapeCount > 1
        var vertexElementCount = 1
        var useBlendNormal = (blendShape as! BlendShape)._useBlendShapeNormal
        var useBlendTangent = (blendShape as! BlendShape)._useBlendShapeTangent
        if notFirst {
            useBlendNormal = useBlendNormal && _useBlendNormal
            useBlendTangent = useBlendTangent && _useBlendTangent
        }

        if useBlendNormal {
            vertexElementCount += 1
        }
        if useBlendTangent {
            vertexElementCount += 1
        }

        _useBlendNormal = useBlendNormal
        _useBlendTangent = useBlendTangent
        _vertexElementCount = vertexElementCount
    }
}
