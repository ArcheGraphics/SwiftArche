//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// The blend state of the render target.
public class RenderTargetBlendState {
    /// Whether to enable blend.
    public var enabled: Bool = false
    /// color (RGB) blend operation.
    public var colorBlendOperation: MTLBlendOperation = .add
    /// alpha (A) blend operation.
    public var alphaBlendOperation: MTLBlendOperation = .add
    /// color blend factor (RGB) for source.
    public var sourceColorBlendFactor: MTLBlendFactor = .one
    /// alpha blend factor (A) for source.
    public var sourceAlphaBlendFactor: MTLBlendFactor = .one
    /// color blend factor (RGB) for destination.
    public var destinationColorBlendFactor: MTLBlendFactor = .zero
    /// alpha blend factor (A) for destination.
    public var destinationAlphaBlendFactor: MTLBlendFactor = .zero
    /// color mask.
    public var colorWriteMask: MTLColorWriteMask = .all
}
