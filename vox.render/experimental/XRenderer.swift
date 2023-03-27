//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

/// Data stored for each view to be rendered.
struct XFrameViewData {
    /// Camera data for view.
    var cameraParamsBuffer: MTLBuffer!
    /// Culling camera params for view.
    var cullParamBuffer: MTLBuffer!
}

/// Options for encoding rendering.
enum XRenderMode {
    /// CPU encoding of draws with a `MTLRenderCommandEncoder`.
    case RenderModeDirect
    /// GPU encoding of draws with an `MTLIndirectCommandBuffer`.
    case RenderModeIndirect
}

class XRenderer {
    /// Initialization.
    init(with view: MTKView) {
    }

    /// Updates the state for frame state based on the current input.
    func updateFrameState() {
    }

    /// Draws the the view.
    func drawInMTKView(view: MTKView) {
    }

    /// Resizes internal structures to the specified resolution.
    func resize(size: CGSize) {
    }
}
