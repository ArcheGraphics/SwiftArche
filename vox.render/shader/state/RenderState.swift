//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Render state.
public class RenderState {
    /// Blend state.
    public var blendState: BlendState = .init()
    /// Depth state.
    public var depthState: DepthState = .init()
    /// Stencil state.
    public var stencilState: StencilState = .init()
    /// Raster state.
    public var rasterState: RasterState = .init()
    /// Render queue type.
    public var renderQueueType: RenderQueueType = .Opaque

    func _apply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                _ depthStencilDescriptor: MTLDepthStencilDescriptor,
                _ renderEncoder: MTLRenderCommandEncoder,
                _ frontFaceInvert: Bool)
    {
        blendState._apply(pipelineDescriptor, renderEncoder)
        depthState._apply(depthStencilDescriptor)
        stencilState._apply(depthStencilDescriptor, renderEncoder)
        rasterState._apply(frontFaceInvert, renderEncoder)
    }
}
