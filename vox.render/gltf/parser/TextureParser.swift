//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import MetalKit

class TextureParser: Parser {
    override func parse(_ context: ParserContext) {
        let gltf = context.glTFResource.gltf!
        var textures: [MTLTexture] = []
        var samplers: [MTLSamplerDescriptor?] = []
        for index in 0..<gltf.textures.count {
            if context.textureIndex != nil && context.textureIndex! != index {
                return
            }

            if let source = gltf.textures[index].source {
                textures.append(newTextureFromImage(source, Engine.device)!)
            }

            if let sampler = gltf.textures[index].sampler {
                let descriptor = MTLSamplerDescriptor()
                switch sampler.magFilter {
                case .nearest:
                    descriptor.magFilter = .nearest
                    break
                case .linear:
                    descriptor.magFilter = .linear
                    break
                default:
                    break
                }

                switch sampler.minMipFilter {
                case .nearest, .nearestNearest, .nearestLinear:
                    descriptor.minFilter = .nearest
                    break
                case .linear, .linearLinear, .linearNearest:
                    descriptor.minFilter = .linear
                    break
                default:
                    break
                }

                switch sampler.minMipFilter {
                case .nearest, .linear, .nearestNearest, .linearNearest:
                    descriptor.mipFilter = .nearest
                    break
                case .nearestLinear, .linearLinear:
                    descriptor.mipFilter = .linear
                    break
                default:
                    break
                }

                switch sampler.wrapS {
                case .clampToEdge:
                    descriptor.sAddressMode = .clampToEdge
                    break
                case .mirroredRepeat:
                    descriptor.sAddressMode = .mirrorRepeat
                    break
                case .repeat:
                    descriptor.sAddressMode = .repeat
                    break
                default:
                    break
                }

                switch sampler.wrapT {
                case .clampToEdge:
                    descriptor.tAddressMode = .clampToEdge
                    break
                case .mirroredRepeat:
                    descriptor.tAddressMode = .mirrorRepeat
                    break
                case .repeat:
                    descriptor.tAddressMode = .repeat
                    break
                default:
                    break
                }
                samplers.append(descriptor)
            } else {
                samplers.append(nil)
            }
        }
        
        // generate all mipmap
        if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
            if let commandEncoder = commandBuffer.makeBlitCommandEncoder() {
                for texture in textures {
                    commandEncoder.generateMipmaps(for: texture)
                }
                commandEncoder.endEncoding()
            }
            commandBuffer.commit()
        }
        
        context.glTFResource.samplers = samplers
        context.glTFResource.textures = textures
    }
}
