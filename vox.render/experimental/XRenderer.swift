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

class XRenderer {
    // Internal structure containing the data for each frame.
    //  Multiple copies exist to allow updating while others are in flight.
    struct AAPLFrameData {
        // AAPLFrameConstants for this frame.
        var frameDataBuffer: MTLBuffer
        // Buffers for each view.
        var viewData: [XFrameViewData] = .init(repeating: XFrameViewData(), count: Int(XConfig.NUM_VIEWS))
        // ICBs and chunk cull information for each view.
        var viewICBData: [XICBData] = .init(repeating: XICBData(), count: Int(XConfig.NUM_VIEWS))

        // Lighting data
        var pointLightsBuffer: MTLBuffer
        var spotLightsBuffer: MTLBuffer
        var lightParamsBuffer: MTLBuffer

        var pointLightsCullingBuffer: MTLBuffer
        var spotLightsCullingBuffer: MTLBuffer
    };

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
