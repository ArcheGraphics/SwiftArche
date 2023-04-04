//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

/// Unlit Material.
public class UnlitMaterial: BaseMaterial {
    /// Base color.
    @Serialized(default: Color(1, 1, 1, 1))
    public var baseColor: Color {
        didSet {
            shaderData.setData(with: UnlitMaterial._baseColorProp, data: baseColor.toLinear())
        }
    }

    /// Base texture.
    public var baseTexture: MTLTexture? {
        didSet {
            if let baseTexture {
                if let srgbFormat = baseTexture.pixelFormat.toSRGB {
                    shaderData.setImageSampler(with: UnlitMaterial._baseTextureProp, UnlitMaterial._baseSamplerProp,
                                               texture: baseTexture.makeTextureView(pixelFormat: srgbFormat))
                } else {
                    shaderData.setImageSampler(with: UnlitMaterial._baseTextureProp,
                                               UnlitMaterial._baseSamplerProp, texture: baseTexture)
                }
                shaderData.enableMacro(HAS_BASE_TEXTURE.rawValue)
            } else {
                shaderData.setImageSampler(with: UnlitMaterial._baseTextureProp,
                                           UnlitMaterial._baseSamplerProp, texture: nil)
                shaderData.disableMacro(HAS_BASE_TEXTURE.rawValue)
            }
        }
    }
    
    public required init() {
        super.init()
        shader = ShaderFactory.unlit
        name = "unlit mat"
    }
    
    override func createArgumentBuffer() {
        super.createArgumentBuffer()
        
        var desc = MTLArgumentDescriptor()
        desc.index = 0
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: UnlitMaterial._baseColorProp, descriptor: desc)
        
        desc = MTLArgumentDescriptor()
        desc.index = 1
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: UnlitMaterial._baseSamplerProp, descriptor: desc)
        
        desc = MTLArgumentDescriptor()
        desc.index = 2
        desc.dataType = .texture
        desc.access = .readOnly
        desc.textureType = .type2D
        shaderData.registerArgumentDescriptor(with: UnlitMaterial._baseTextureProp, descriptor: desc)
        shaderData.createArgumentBuffer(with: "u_unlitMaterial")

        shaderData.enableMacro(OMIT_NORMAL.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)
        shaderData.setData(with: UnlitMaterial._baseColorProp, data: baseColor.toLinear())
    }
}
