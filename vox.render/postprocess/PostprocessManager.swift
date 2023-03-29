//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class PostprocessManager {
    var _canvas: Canvas
    weak var _scene: Scene!
    var _shaderData: ShaderData
    var _postprocessData = PostprocessData(manualExposureValue: 0.5, exposureKey: 0.25)

    // default pass
    public var gammeCorrectionPass: GammaCorrection
    public var luminancePass: Luminance

    /// manual exposure
    public var manualExposure: Float {
        get {
            _postprocessData.manualExposureValue
        }
        set {
            _postprocessData.manualExposureValue = newValue
            _shaderData.setData("u_postprocess", _postprocessData)
        }
    }

    /// exposure key used in auto mode
    public var exposureKey: Float {
        get {
            _postprocessData.exposureKey
        }
        set {
            _postprocessData.exposureKey = newValue
            _shaderData.setData("u_postprocess", _postprocessData)
        }
    }

    // enable auto exposure
    public var autoExposure: Bool = false {
        didSet {
            gammeCorrectionPass.autoExposure = autoExposure
        }
    }

    init(_ scene: Scene) {
        _scene = scene
        _canvas = Engine.canvas!
        _shaderData = scene.shaderData
        _shaderData.setData("u_postprocess", _postprocessData)

        luminancePass = Luminance(scene)
        gammeCorrectionPass = GammaCorrection(scene)
    }

    func compute(with commandBuffer: MTLCommandBuffer) {
        let luminanceTaskData = luminancePass.compute(with: commandBuffer, label: "luminance")
        gammeCorrectionPass.compute(with: commandBuffer, luminance: luminanceTaskData.output, label: "gamme correction")
    }
}
