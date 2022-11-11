//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Depth state.
public class DepthState {
    /// Whether to enable the depth test.
    public var enabled: Bool = true
    /// Whether the depth value can be written.
    public var writeEnabled: Bool = true
    /// Depth comparison function.
    public var compareFunction: MTLCompareFunction = .less

    func _apply(_ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        if (enabled) {
            // apply compare func.
            depthStencilDescriptor.depthCompareFunction = compareFunction

            // apply write enabled.
            depthStencilDescriptor.isDepthWriteEnabled = writeEnabled
        }
    }
}
