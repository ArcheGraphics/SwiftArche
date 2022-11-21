//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import Metal

public class BlendShapeManager {
    private static let _blendShapeWeightsProperty = "u_blendShapeWeights"
    private static let _blendShapeTextureProperty = "u_blendShapeTexture"
    private static let _blendShapeTextureInfoProperty = "u_blendShapeTextureInfo"

    var _blendShapeCount: Int = 0
    var _blendShapes: [BlendShape] = []
    var _blendShapeNames: [String] = []
    var _subDataDirtyFlags: [BoolUpdateFlag] = []
    var _listenerFlags: [ListenerUpdateFlag] = []
    var _vertexTexture: MTLTexture!

    private var _useBlendNormal: Bool = false
    private var _useBlendTangent: Bool = false
    private var _vertexElementCount: Int = 0
    private var _vertexElementOffset: Int = 0
    private var _storeInVertexBufferInfo: [Vector2] = []
    private var _engine: Engine
    private var _modelMesh: ModelMesh
    private var _lastCreateHostInfo: Vector3 = Vector3(0, 0, 0)
    private var _dataTextureInfo: Vector3 = Vector3()

    init(_ engine: Engine, _ modelMesh: ModelMesh) {
        _engine = engine
        _modelMesh = modelMesh
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
        if (_blendShapeCount > 0) {
            shaderData.enableMacro(HAS_BLENDSHAPE)
            shaderData.setImageView(BlendShapeManager._blendShapeTextureProperty, "", _vertexTexture)
            shaderData.setData(BlendShapeManager._blendShapeTextureInfoProperty, _dataTextureInfo)
            shaderData.setData(BlendShapeManager._blendShapeWeightsProperty, skinnedMeshRenderer.blendShapeWeights)
            shaderData.enableMacro(BLENDSHAPE_COUNT, (_blendShapeCount, .int))

            if (_useBlendNormal) {
                shaderData.enableMacro(HAS_BLENDSHAPE_NORMAL)
            } else {
                shaderData.disableMacro(HAS_BLENDSHAPE_NORMAL)
            }
            if (_useBlendTangent) {
                shaderData.enableMacro(HAS_BLENDSHAPE_TANGENT)
            } else {
                shaderData.disableMacro(HAS_BLENDSHAPE_TANGENT)
            }
        } else {
            shaderData.disableMacro(HAS_BLENDSHAPE)
            shaderData.disableMacro(BLENDSHAPE_COUNT)
        }
    }

    func _layoutOrCountChange() -> Bool {
        Int(_lastCreateHostInfo.x) != _blendShapeCount ||
                (_lastCreateHostInfo.y != 0) != _useBlendNormal ||
                (_lastCreateHostInfo.z != 0) != _useBlendTangent
    }

    func _needUpdateData() -> Bool {
        for subDataDirtyFlag in _subDataDirtyFlags {
            if (subDataDirtyFlag.flag) {
                return true
            }
        }
        return false
    }

    func _update(_ vertexCountChange: Bool, _ noLongerAccessible: Bool) {
        let createHost = _layoutOrCountChange() || vertexCountChange
        if (createHost) {
            _createTextureArray(_modelMesh.vertexCount)
            _ = _lastCreateHostInfo.set(x: Float(_blendShapeCount), y: _useBlendNormal ? 1.0 : 0.0, z: _useBlendTangent ? 1.0 : 0.0)
        }
        if (_needUpdateData()) {
            _updateTextureArray(_modelMesh.vertexCount, createHost)
        }
    }

    func _releaseMemoryCache() {
        var blendShapeNamesMap = [String](repeating: "", count: _blendShapes.count)
        for i in 0..<_blendShapes.count {
            blendShapeNamesMap[i] = _blendShapes[i].name
        }
        _blendShapeNames = blendShapeNamesMap

        _listenerFlags = []
        _subDataDirtyFlags = []
        _blendShapes = []
    }

    private func _createTextureArray(_ vertexCount: Int) {
    }

    private func _updateTextureArray(_ vertexCount: Int, _ force: Bool) {
    }

    private func _updateLayoutChange(_ a: Int?, _ blendShape: AnyObject?) {
        let notFirst = _blendShapeCount > 1
        var vertexElementCount = 1
        var useBlendNormal = (blendShape as! BlendShape)._useBlendShapeNormal
        var useBlendTangent = (blendShape as! BlendShape)._useBlendShapeTangent
        if (notFirst) {
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