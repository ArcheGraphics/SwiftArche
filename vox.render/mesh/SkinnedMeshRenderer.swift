//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import Metal
import simd

public class SkinnedMeshRenderer: MeshRenderer {
    private static let _jointCountProperty = "u_jointCount"
    private static let _jointSamplerProperty = "u_jointSampler"
    private static let _jointMatrixProperty = "u_jointMatrix"
    private static var _maxJoints: Int = 0

    private var _hasInitJoints: Bool = false
    /// Whether to use joint texture. Automatically used when the device can't support the maximum number of bones.
    private var _useJointTexture: Bool = false
    private var _skin: Skin?
    private var _blendShapeWeights: [Float] = []
    private var _maxVertexUniformVectors: Int = 256
    private var _rootBone: Entity?
    private var _localBounds: BoundingBox = BoundingBox()
    private var _jointMatrixs: [simd_float4x4] = []
    private var _jointTexture: MTLTexture?
    private var _jointEntities: [Entity] = []

    var _condensedBlendShapeWeights: [Float] = []

    /// The weights of the BlendShapes.
    /// - Remark: Array index is BlendShape index.
    var blendShapeWeights: [Float] {
        get {
            _checkBlendShapeWeightLength()
            return _blendShapeWeights
        }
        set {
            _checkBlendShapeWeightLength()
            if (newValue.count <= _blendShapeWeights.count) {
                _blendShapeWeights = newValue
            } else {
                for i in 0..<_blendShapeWeights.count {
                    _blendShapeWeights[i] = newValue[i]
                }
            }
        }
    }

    /// Skin Object.
    var skin: Skin? {
        get {
            _skin
        }
        set {
            if (_skin !== newValue) {
                _skin = newValue
                _hasInitJoints = false
            }
        }
    }

    /// Local bounds.
    var localBounds: BoundingBox {
        get {
            _localBounds
        }
        set {
            _localBounds = newValue
            _onLocalBoundsChanged()
        }
    }

    /// Root bone.
    var rootBone: Entity? {
        get {
            _rootBone
        }
        set {
            _rootBone = newValue
            _dirtyUpdateFlag |= RendererUpdateFlags.WorldVolume.rawValue
        }
    }

    func update() {
    }

    override func _updateShaderData(_ cameraInfo: CameraInfo) {
    }

    override func _updateBounds(_ worldBounds: inout BoundingBox) {
    }

    private func _createJointTexture() {
    }

    private func _initJoints() {
    }

    private func _findByEntityName(_ rootEntity: Entity?, _ name: String) -> Entity? {
        if (rootEntity == nil) {
            return nil
        }

        let result = rootEntity!.findByName(name)
        if (result != nil) {
            return result
        }

        return _findByEntityName(rootEntity!.parent, name)
    }

    private func _checkBlendShapeWeightLength() {
        let mesh = _mesh as? ModelMesh
        let newBlendShapeCount = mesh != nil ? mesh!.blendShapeCount : 0
        if (!_blendShapeWeights.isEmpty) {
            if (_blendShapeWeights.count != newBlendShapeCount) {
                var newBlendShapeWeights = [Float](repeating: 0, count: newBlendShapeCount)
                if (newBlendShapeCount > _blendShapeWeights.count) {
                    newBlendShapeWeights.insert(contentsOf: _blendShapeWeights, at: 0)
                } else {
                    for i in 0..<newBlendShapeCount {
                        newBlendShapeWeights[i] = _blendShapeWeights[i]
                    }
                }
                _blendShapeWeights = newBlendShapeWeights
            }
        } else {
            _blendShapeWeights = [Float](repeating: 0, count: newBlendShapeCount)
        }
    }

    private func _onLocalBoundsChanged() {
        _dirtyUpdateFlag |= RendererUpdateFlags.WorldVolume.rawValue
    }
}