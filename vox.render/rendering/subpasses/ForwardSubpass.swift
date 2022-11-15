//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class ForwardSubpass : Subpass {
    override func draw(_ encoder: MTLRenderCommandEncoder) {
        let pipeline = _renderPass.pipeline!
        pipeline._opaqueQueue.removeAll()
        pipeline._alphaTestQueue.removeAll()
        pipeline._transparentQueue.removeAll()
        pipeline.callRender(pipeline.camera._cameraInfo)
        pipeline._opaqueQueue.sort(by: DevicePipeline._compareFromNearToFar);
        pipeline._alphaTestQueue.sort(by: DevicePipeline._compareFromNearToFar);
        pipeline._transparentQueue.sort(by: DevicePipeline._compareFromFarToNear);

        encoder.endEncoding()
    }
}