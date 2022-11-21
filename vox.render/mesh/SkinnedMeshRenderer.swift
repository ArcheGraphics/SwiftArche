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
    private var _jointBuffer: MTLBuffer?
    private var _jointTexture: MTLTexture?
    private var _jointEntities: [Entity] = []
    private var _listenerFlag: ListenerUpdateFlag?

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
        let worldMatrix = _rootBone != nil ? _rootBone!.transform.worldMatrix : entity.transform.worldMatrix
        _updateTransformShaderData(cameraInfo, worldMatrix)

        if (!_useJointTexture && !_jointMatrixs.isEmpty) {
            shaderData.setData(SkinnedMeshRenderer._jointMatrixProperty, _jointMatrixs)
        }

        let mesh = mesh as! ModelMesh
        mesh._blendShapeManager._updateShaderData(shaderData, self)
    }

    override func _updateBounds(_ worldBounds: inout BoundingBox) {
        if (_rootBone != nil) {
            let worldMatrix = _rootBone!.transform.worldMatrix
            worldBounds = BoundingBox.transform(source: localBounds, matrix: worldMatrix)
        } else {
            super._updateBounds(&worldBounds)
        }
    }

    private func _createJointTexture() {
        if (_jointTexture == nil) {
            let descriptor = MTLTextureDescriptor()
            descriptor.width = 4
            descriptor.height = _jointEntities.count
            descriptor.pixelFormat = .rgba32Float
            descriptor.mipmapLevelCount = 1
            _jointTexture = engine.device.makeTexture(descriptor: descriptor)
            shaderData.enableMacro(HAS_JOINT_TEXTURE)
            shaderData.setImageView(SkinnedMeshRenderer._jointSamplerProperty, "", _jointTexture)
        }

        if let commandBuffer = _engine.commandQueue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeBlitCommandEncoder() {
            _jointBuffer!.contents().copyMemory(from: _jointMatrixs, byteCount: _jointMatrixs.count * MemoryLayout<simd_float4x4>.stride)
            commandEncoder.copy(from: _jointBuffer!, sourceOffset: 0, sourceBytesPerRow: 0, sourceBytesPerImage: 0, sourceSize: MTLSize(),
                    to: _jointTexture!, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin())
            commandEncoder.endEncoding()
            commandBuffer.commit()
        }
    }

    private func _initJoints() {
        if (skin == nil) {
            shaderData.disableMacro(HAS_SKIN)
            return
        }

        let joints = skin!.joints
        let jointCount = joints.count
        var jointEntities: [Entity] = []
        for i in 0..<jointCount {
            jointEntities.append(_findByEntityName(entity, joints[i])!)
        }
        _jointEntities = jointEntities
        _jointMatrixs = [simd_float4x4](repeating: simd_float4x4(), count: jointCount)
        _jointBuffer = engine.device.makeBuffer(length: jointCount * MemoryLayout<simd_float4x4>.stride)

        let lastRootBone = _rootBone
        let rootBone = _findByEntityName(entity, skin!.skeleton)

        if lastRootBone != nil {
            lastRootBone!.transform._updateFlagManager.removeFlag(flag: _listenerFlag!)
        }
        _listenerFlag = ListenerUpdateFlag()
        _listenerFlag!.listener = _onTransformChanged
        rootBone!.transform._updateFlagManager.addFlag(flag: _listenerFlag!)

        let rootIndex = joints.firstIndex { v in
            v == skin!.skeleton
        }
        if (rootIndex != nil) {
            _localBounds = BoundingBox.transform(source: _mesh!.bounds, matrix: skin!.inverseBindMatrices[rootIndex!])
        } else {
            // Root bone is not in joints list,we can only use default pose compute local bounds
            // Default pose is slightly less accurate than bind pose
            let inverseRootBone = Matrix.invert(a: rootBone!.transform.worldMatrix)
            _localBounds = BoundingBox.transform(source: _mesh!.bounds, matrix: inverseRootBone)
        }

        _rootBone = rootBone

        let maxJoints = Int(floor(Float(_maxVertexUniformVectors - 30) / 4.0))

        if (jointCount != 0) {
            shaderData.enableMacro(HAS_SKIN)
            shaderData.setData(SkinnedMeshRenderer._jointCountProperty, jointCount)
            if (jointCount > maxJoints) {
                _useJointTexture = true
            } else {
                let maxJoints = max(SkinnedMeshRenderer._maxJoints, jointCount)
                SkinnedMeshRenderer._maxJoints = maxJoints
                shaderData.disableMacro(HAS_JOINT_TEXTURE)
                shaderData.enableMacro(JOINTS_COUNT, (maxJoints, .int))
            }
        } else {
            shaderData.disableMacro(HAS_SKIN)
        }
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