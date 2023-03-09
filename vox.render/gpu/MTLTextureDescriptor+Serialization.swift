//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

internal class MTLTextureDescriptorCodableBox: Codable {
    let descriptor: MTLTextureDescriptor

    init(descriptor: MTLTextureDescriptor) {
        self.descriptor = descriptor
    }

    required init(from decoder: Decoder) throws {
        descriptor = try MTLTextureDescriptor(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try descriptor.encode(to: encoder)
    }
}

extension MTLTextureDescriptor: Encodable {
    internal enum CodingKeys: String, CodingKey {
        case width
        case height
        case depth
        case arrayLength
        case storageMode
        case cpuCacheMode
        case usage
        case textureType
        case sampleCount
        case mipmapLevelCount
        case pixelFormat
        case allowGPUOptimizedContents
    }

    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        depth = try container.decode(Int.self, forKey: .depth)
        arrayLength = try container.decode(Int.self, forKey: .arrayLength)
        cpuCacheMode = try container.decode(MTLCPUCacheMode.self, forKey: .cpuCacheMode)
        usage = try container.decode(MTLTextureUsage.self, forKey: .usage)
        textureType = try container.decode(MTLTextureType.self, forKey: .textureType)
        sampleCount = try container.decode(Int.self, forKey: .sampleCount)
        mipmapLevelCount = try container.decode(Int.self, forKey: .mipmapLevelCount)
        pixelFormat = try container.decode(MTLPixelFormat.self, forKey: .pixelFormat)

        if #available(iOS 12, macOS 10.14, *) {
            allowGPUOptimizedContents = (try? container.decode(Bool.self, forKey: .allowGPUOptimizedContents)) ?? true
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(depth, forKey: .depth)
        try container.encode(arrayLength, forKey: .arrayLength)
        try container.encode(cpuCacheMode, forKey: .cpuCacheMode)
        try container.encode(usage, forKey: .usage)
        try container.encode(textureType, forKey: .textureType)
        try container.encode(sampleCount, forKey: .sampleCount)
        try container.encode(mipmapLevelCount, forKey: .mipmapLevelCount)
        try container.encode(pixelFormat, forKey: .pixelFormat)

        if #available(iOS 12, macOS 10.14, *) {
            try container.encode(allowGPUOptimizedContents, forKey: .allowGPUOptimizedContents)
        }
    }
}
