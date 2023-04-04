//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class ParticleCapsuleCollider: ParticleCollider {
    private var capsuleBuffer: BufferView?
    public var capsuleData: [CapsuleColliderShapeData] = []

    override public init() {
        super.init()
        shader.append(ShaderPass(Engine.library("flex.shader"), "capsuleCollider"))
    }

    override public func update(commandEncoder: MTLComputeCommandEncoder,
                                indirectBuffer: MTLBuffer, threadsPerThreadgroup: MTLSize)
    {
        if capsuleBuffer == nil || capsuleBuffer!.count != capsuleData.count {
            capsuleBuffer = BufferView(array: capsuleData)
        } else {
            capsuleBuffer!.assign(with: capsuleData)
        }
        defaultShaderData.setData("u_capsules", capsuleBuffer!)

        if capsuleData.count != _colliderData.count {
            _colliderData.count = UInt32(capsuleData.count)
            defaultShaderData.setData(ParticleCollider.colliderProperty, _colliderData)
        }

        super.compute(commandEncoder: commandEncoder, indirectBuffer: indirectBuffer,
                      threadsPerThreadgroup: threadsPerThreadgroup, label: "capsule collider")
    }
}
