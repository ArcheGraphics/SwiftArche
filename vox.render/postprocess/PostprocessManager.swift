//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class PostprocessManager {
    private static let _manualExposureValueProperty = "u_manualExposureValue"
    private static let _exposureKeyProperty = "u_exposureKey"

    var _canvas: Canvas
    weak var _scene: Scene!
    var _shaderData: ShaderData

    // default pass
    public var gammeCorrectionPass: GammaCorrection
    public var luminancePass: Luminance

    /// manual exposure
    public var manualExposure: Float = 0.5 {
        didSet {
            _shaderData.setData(with: PostprocessManager._manualExposureValueProperty, data: manualExposure)
        }
    }

    /// exposure key used in auto mode
    public var exposureKey: Float = 0.5 {
        didSet {
            _shaderData.setData(with: PostprocessManager._exposureKeyProperty, data: exposureKey)
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

        var desc = MTLArgumentDescriptor()
        desc.index = 0
        desc.dataType = .float
        desc.access = .readOnly
        _shaderData.registerArgumentDescriptor(with: PostprocessManager._manualExposureValueProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 1
        desc.dataType = .float
        desc.access = .readOnly
        _shaderData.registerArgumentDescriptor(with: PostprocessManager._exposureKeyProperty, descriptor: desc)
        _shaderData.createArgumentBuffer(with: "u_postprocess")

        _shaderData.setData(with: PostprocessManager._manualExposureValueProperty, data: manualExposure)
        _shaderData.setData(with: PostprocessManager._exposureKeyProperty, data: exposureKey)

        luminancePass = Luminance(scene)
        gammeCorrectionPass = GammaCorrection(scene)
    }

    func compute(with commandBuffer: MTLCommandBuffer) {
        let luminanceTaskData = luminancePass.compute(with: commandBuffer, label: "luminance")
        gammeCorrectionPass.compute(with: commandBuffer, luminance: luminanceTaskData.output, label: "gamme correction")
    }
}
