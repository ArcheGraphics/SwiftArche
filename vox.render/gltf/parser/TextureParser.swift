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
        for index in 0 ..< gltf.textures.count {
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
                case .linear:
                    descriptor.magFilter = .linear
                default:
                    break
                }

                switch sampler.minMipFilter {
                case .nearest, .nearestNearest, .nearestLinear:
                    descriptor.minFilter = .nearest
                case .linear, .linearLinear, .linearNearest:
                    descriptor.minFilter = .linear
                default:
                    break
                }

                switch sampler.minMipFilter {
                case .nearest, .linear, .nearestNearest, .linearNearest:
                    descriptor.mipFilter = .nearest
                case .nearestLinear, .linearLinear:
                    descriptor.mipFilter = .linear
                default:
                    break
                }

                switch sampler.wrapS {
                case .clampToEdge:
                    descriptor.sAddressMode = .clampToEdge
                case .mirroredRepeat:
                    descriptor.sAddressMode = .mirrorRepeat
                case .repeat:
                    descriptor.sAddressMode = .repeat
                default:
                    break
                }

                switch sampler.wrapT {
                case .clampToEdge:
                    descriptor.tAddressMode = .clampToEdge
                case .mirroredRepeat:
                    descriptor.tAddressMode = .mirrorRepeat
                case .repeat:
                    descriptor.tAddressMode = .repeat
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
