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
    private static let _jointTextureProperty = "u_jointTexture"
    private static let _jointSamplerProperty = "u_jointSampler"
    private static let _jointMatrixProperty = "u_jointMatrix"
    private static var _maxJoints: Int = 256

    private var _hasInitJoints: Bool = false
    /// Whether to use joint texture. Automatically used when the device can't support the maximum number of bones.
    private var _useJointTexture: Bool = false
    private var _animator: Animator?
    
    private var _blendShapeWeights: [Float] = []
    private var _maxVertexUniformVectors: Int = 256
    private var _localBounds: BoundingBox = BoundingBox()
    private var _skinningMatrices: [simd_float4x4] = []
    private var _jointTexture: MTLTexture?
    private var _listenerFlag: ListenerUpdateFlag?

    var _condensedBlendShapeWeights: [Float] = []

    /// The weights of the BlendShapes.
    /// - Remark: Array index is BlendShape index.
    public var blendShapeWeights: [Float] {
        get {
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
    
    /// Mesh assigned to the renderer.
    public override var mesh: Mesh? {
        get {
            _mesh
        }
        set {
            if let skinnedMesh = newValue as? SkinnedMesh {
                setSkinnedMesh(with: skinnedMesh, at: 0)
            }
            super.mesh = newValue
        }
    }
    
    public func setSkinnedMesh(with mesh: SkinnedMesh, at index: Int) {
        let jointCount = mesh.skinningMatricesCount(at: index)
        if (jointCount != 0) {
            // Allocates skinning matrices.
            _skinningMatrices = [simd_float4x4](repeating: simd_float4x4(), count: jointCount)
            
            shaderData.enableMacro(HAS_SKIN.rawValue)
            shaderData.setData(SkinnedMeshRenderer._jointCountProperty, jointCount)
            if (jointCount > SkinnedMeshRenderer._maxJoints) {
                _useJointTexture = true
            } else {
                let maxJoints = max(SkinnedMeshRenderer._maxJoints, jointCount)
                SkinnedMeshRenderer._maxJoints = maxJoints
                shaderData.disableMacro(HAS_JOINT_TEXTURE.rawValue)
            }
        } else {
            shaderData.disableMacro(HAS_SKIN.rawValue)
        }
    }

    override func update(_ deltaTime: Float) {
        if _animator == nil {
            _animator = entity.getComponent(Animator.self)
        }
        
        if let animator = _animator,
           let skinnedMesh = _mesh as? SkinnedMesh {
            skinnedMesh.getSkinningMatrices(at: 0, animator: animator, matrix: &_skinningMatrices)
        }
    }

    override func _updateShaderData(_ cameraInfo: CameraInfo) {
        _updateTransformShaderData(cameraInfo, entity.transform.worldMatrix)

        if (!_useJointTexture && !_skinningMatrices.isEmpty) {
            shaderData.setData(SkinnedMeshRenderer._jointMatrixProperty, _skinningMatrices)
        }

        let mesh = mesh as! ModelMesh
        mesh._blendShapeManager._updateShaderData(shaderData, self)
    }

    override func _updateBounds(_ worldBounds: inout BoundingBox) {
        super._updateBounds(&worldBounds)
    }

    private func _createJointTexture() {
        if (_jointTexture == nil) {
            let descriptor = MTLTextureDescriptor()
            descriptor.width = 4
            descriptor.height = _skinningMatrices.count
            descriptor.pixelFormat = .rgba32Float
            descriptor.mipmapLevelCount = 1
            _jointTexture = engine.device.makeTexture(descriptor: descriptor)
            shaderData.enableMacro(HAS_JOINT_TEXTURE.rawValue)
            shaderData.setImageView(SkinnedMeshRenderer._jointTextureProperty, SkinnedMeshRenderer._jointSamplerProperty, _jointTexture)

            let samplerDesc = MTLSamplerDescriptor()
            samplerDesc.mipFilter = .nearest
            samplerDesc.magFilter = .nearest
            samplerDesc.mipFilter = .nearest
            shaderData.setSampler(SkinnedMeshRenderer._jointSamplerProperty, samplerDesc)
        }

        if let texture = _jointTexture {
            texture.replace(region: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                    size: MTLSize(width: texture.width, height: texture.height, depth: 1)),
                            mipmapLevel: 0, withBytes: &_skinningMatrices, bytesPerRow: 16 * MemoryLayout<Float>.stride)
        }
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
