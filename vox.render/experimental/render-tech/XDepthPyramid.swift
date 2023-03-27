//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class XDepthPyramid {
    /// Initializes this helper, pre-allocating objects from the device.
    init(with device: MTLDevice, library: MTLLibrary) {
    }

    /// Generates the depth pyramid texture from the specified depth texture.
    ///  Supports both being the same texture.
    func generate(pyramidTexture: MTLTexture,
                  depthTexture: MTLTexture,
                  onEncoder: MTLComputeCommandEncoder) {
    }

    /// Checks if the specified pyramid texture is valid for the depth texture.
    ///  If not, it should be allocated with allocatePyramidTextureFromDepth.
    static func isPyramidTextureValid(for pyramidTexture: MTLTexture, depthTexture: MTLTexture) -> Bool {
        false
    }

    /// Allocates a pyramid texture based on the depth texture it will downsample.
    static func allocatePyramidTexture(from depthTexture: MTLTexture, device: MTLDevice) -> MTLTexture? {
        nil
    }
}
