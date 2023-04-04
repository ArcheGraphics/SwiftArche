//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
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
    private var _skinnedMeshIndex: Int = 0

    private var _maxVertexUniformVectors: Int = 256
    private var _localBounds: BoundingBox = .init()
    private var _skinningMatrices: [simd_float4x4] = []
    private var _jointTexture: MTLTexture?
    private var _listenerFlag: ListenerUpdateFlag?

    var _condensedBlendShapeWeights: [Float] = []

    /// The weights of the BlendShapes.
    /// - Remark: Array index is BlendShape index.
    public var blendShapeWeights: [Float] = [] {
        didSet {
            _checkBlendShapeWeightLength()
        }
    }

    public func setSkinnedMeshTarget(for index: Int) {
        if let mesh = _mesh as? SkinnedMesh {
            _skinnedMeshIndex = index
            let jointCount = mesh.skinningMatricesCount(at: index)
            if jointCount != 0 {
                // Allocates skinning matrices.
                _skinningMatrices = [simd_float4x4](repeating: simd_float4x4(), count: jointCount)

                shaderData.enableMacro(HAS_SKIN.rawValue)
                shaderData.setData(with: SkinnedMeshRenderer._jointCountProperty, data: jointCount)
                if jointCount > SkinnedMeshRenderer._maxJoints {
                    _useJointTexture = true
                } else {
                    let maxJoints = max(SkinnedMeshRenderer._maxJoints, jointCount)
                    SkinnedMeshRenderer._maxJoints = maxJoints
                    shaderData.disableMacro(HAS_JOINT_TEXTURE.rawValue)
                }
            } else {
                shaderData.disableMacro(HAS_SKIN.rawValue)
            }
        } else {
            shaderData.disableMacro(HAS_SKIN.rawValue)
        }
    }

    override func _render(_ devicePipeline: DevicePipeline) {
        let mesh: Mesh?
        if let skinnedMesh = _mesh as? SkinnedMesh {
            mesh = skinnedMesh._meshes[_skinnedMeshIndex]
        } else {
            mesh = _mesh
        }

        if let mesh {
            if _dirtyUpdateFlag & MeshRendererUpdateFlags.VertexElementMacro.rawValue != 0 {
                let vertexDescriptor = mesh._vertexDescriptor
                shaderData.disableMacro(HAS_UV.rawValue)
                shaderData.disableMacro(HAS_NORMAL.rawValue)
                shaderData.disableMacro(HAS_TANGENT.rawValue)
                shaderData.disableMacro(HAS_VERTEXCOLOR.rawValue)

                if vertexDescriptor.attributes[Int(UV_0.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_UV.rawValue)
                }
                if vertexDescriptor.attributes[Int(Normal.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_NORMAL.rawValue)
                }
                if vertexDescriptor.attributes[Int(Tangent.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_TANGENT.rawValue)
                }
                if vertexDescriptor.attributes[Int(Color_0.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_VERTEXCOLOR.rawValue)
                }
                _dirtyUpdateFlag &= ~MeshRendererUpdateFlags.VertexElementMacro.rawValue
            }

            let subMeshes = mesh.subMeshes
            for i in 0 ..< subMeshes.count {
                let material: Material?
                if i < _materials.count {
                    material = _materials[i]
                } else {
                    material = nil
                }
                if material != nil {
                    let renderData = MeshRenderData(renderer: self, material: material!,
                                                    mesh: mesh, subMesh: subMeshes[i])
                    devicePipeline.pushRenderData(renderData)
                }
            }
        }
    }

    override func update(_: Float) {
        if _animator == nil {
            _animator = entity.getComponent(Animator.self)
        }

        if let animator = _animator,
           let skinnedMesh = _mesh as? SkinnedMesh
        {
            skinnedMesh.getSkinningMatrices(at: _skinnedMeshIndex, animator: animator, matrix: &_skinningMatrices)
        }
    }

    override func _updateShaderData(_ cameraInfo: CameraInfo) {
        _updateTransformShaderData(cameraInfo, entity.transform.worldMatrix)

        if !_useJointTexture && !_skinningMatrices.isEmpty {
            shaderData.setData(with: SkinnedMeshRenderer._jointMatrixProperty, array: _skinningMatrices)
        }

        if let mesh = mesh as? ModelMesh {
            mesh._blendShapeManager._updateShaderData(shaderData, self)
        }
    }

    override func _updateBounds(_ worldBounds: inout BoundingBox) {
        super._updateBounds(&worldBounds)
        if let animator = _animator {
            let localBounds = animator.computeSkeletonBounds()
            let worldMatrix = _entity.transform.worldMatrix
            worldBounds = BoundingBox.transform(source: localBounds, matrix: worldMatrix)
        }
    }

    override func _onDestroy() {
        super._onDestroy()
        if let mesh = _mesh as? SkinnedMesh {
            mesh.destroy()
        }
    }

    private func _createJointTexture() {
        if _jointTexture == nil {
            let descriptor = MTLTextureDescriptor()
            descriptor.width = 4
            descriptor.height = _skinningMatrices.count
            descriptor.pixelFormat = .rgba32Float
            descriptor.mipmapLevelCount = 1
            _jointTexture = Engine.device.makeTexture(descriptor: descriptor)
            shaderData.enableMacro(HAS_JOINT_TEXTURE.rawValue)
            shaderData.setImageSampler(with: SkinnedMeshRenderer._jointTextureProperty,
                                       SkinnedMeshRenderer._jointSamplerProperty, texture: _jointTexture)

            let samplerDesc = MTLSamplerDescriptor()
            samplerDesc.mipFilter = .nearest
            samplerDesc.magFilter = .nearest
            samplerDesc.mipFilter = .nearest
            shaderData.setSampler(with: SkinnedMeshRenderer._jointSamplerProperty, sampler: samplerDesc)
        }

        if let texture = _jointTexture {
            texture.replace(region: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                                              size: MTLSize(width: texture.width, height: texture.height, depth: 1)),
                            mipmapLevel: 0, withBytes: &_skinningMatrices, bytesPerRow: 16 * MemoryLayout<Float>.stride)
        }
    }

    private func _checkBlendShapeWeightLength() {
        if let mesh = _mesh as? ModelMesh {
            let newBlendShapeCount = mesh.blendShapeCount
            if !blendShapeWeights.isEmpty {
                if blendShapeWeights.count != newBlendShapeCount {
                    var newBlendShapeWeights = [Float](repeating: 0, count: newBlendShapeCount)
                    if newBlendShapeCount > blendShapeWeights.count {
                        newBlendShapeWeights.insert(contentsOf: blendShapeWeights, at: 0)
                    } else {
                        for i in 0 ..< newBlendShapeCount {
                            newBlendShapeWeights[i] = blendShapeWeights[i]
                        }
                    }
                    blendShapeWeights = newBlendShapeWeights
                }
            } else {
                blendShapeWeights = [Float](repeating: 0, count: newBlendShapeCount)
            }
        }
    }

    private func _onLocalBoundsChanged() {
        _dirtyUpdateFlag |= RendererUpdateFlags.WorldVolume.rawValue
    }
}
