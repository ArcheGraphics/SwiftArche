//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import ModelIO
import MetalKit

class TextureParser: Parser {
    override func parse(_ context: ParserContext) {
        let gltf = context.glTFResource.gltf!
        var textures: [MTLTexture] = []
        var samplers: [MTLSamplerDescriptor] = []
        for index in 0..<gltf.textures.count {
            if context.textureIndex != nil && context.textureIndex! != index {
                return
            }

            if let source = gltf.textures[index].source {
                if let uri = source.uri {
                    let mdlTexture = MDLURLTexture(url: uri, name: source.name ?? "")
                    if let tex = try? loadTexture(context.glTFResource.engine.device, mdlTexture) {
                        textures.append(tex)
                    }
                } else {
                    let cgImage: CGImage = source.newCGImage() as! CGImage
                    let width = cgImage.width
                    let height = cgImage.height
                    let dataProvider = cgImage.dataProvider!
                    let data = dataProvider.data
                    let mdlTexture = MDLTexture(data: data as Data?, topLeftOrigin: true, name: source.name ?? "",
                            dimensions: vector_int2(Int32(width), Int32(height)),
                            rowStride: width * 4, channelCount: 4, channelEncoding: .uint8, isCube: false)
                    if let tex = try? loadTexture(context.glTFResource.engine.device, mdlTexture) {
                        textures.append(tex)
                    }
                }
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
            }
        }
        context.glTFResource.samplers = samplers
        context.glTFResource.textures = textures
    }

    /// static method to load texture from a instance of MDLTexture
    /// - Parameter device: device
    /// - Parameter texture: a source of texel data
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    func loadTexture(_ device: MTLDevice, _ texture: MDLTexture) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.topLeft,
                 .SRGB: false,
                 .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
                 .generateMipmaps: NSNumber(booleanLiteral: true)]
        let texture = try? textureLoader.newTexture(texture: texture,
                options: textureLoaderOptions)
        return texture
    }
}