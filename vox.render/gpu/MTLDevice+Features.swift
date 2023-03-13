//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public enum Feature {
    case nonUniformThreadgroups
    case readWriteTextures(MTLPixelFormat)
}

public extension MTLDevice {
    func supports(feature: Feature) -> Bool {
        switch feature {
        case .nonUniformThreadgroups:
            #if targetEnvironment(macCatalyst)
            return supportsFamily(.common3)
            #elseif os(iOS)
            return supportsFamily(.apple8)
            #elseif os(macOS)
            return supportsFamily(.mac2)
            #endif

        case let .readWriteTextures(pixelFormat):
            let tierOneSupportedPixelFormats: Set<MTLPixelFormat> = [
                .r32Float, .r32Uint, .r32Sint
            ]
            let tierTwoSupportedPixelFormats: Set<MTLPixelFormat> = tierOneSupportedPixelFormats.union([
                .rgba32Float, .rgba32Uint, .rgba32Sint, .rgba16Float,
                .rgba16Uint, .rgba16Sint, .rgba8Unorm, .rgba8Uint,
                .rgba8Sint, .r16Float, .r16Uint, .r16Sint,
                .r8Unorm, .r8Uint, .r8Sint
            ])

            switch self.readWriteTextureSupport {
            case .tier1: return tierOneSupportedPixelFormats.contains(pixelFormat)
            case .tier2: return tierTwoSupportedPixelFormats.contains(pixelFormat)
            case .tierNone: return false
            @unknown default: return false
            }
        }
    }
}
