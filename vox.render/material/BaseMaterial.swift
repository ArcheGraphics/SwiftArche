//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

open class BaseMaterial: Material {
    public static let _tilingOffsetProp = "u_tilingOffset"

    public static let _baseColorProp = "u_baseColor"
    public static let _baseTextureProp = "u_baseTexture"
    public static let _baseSamplerProp = "u_baseSampler"

    public static let _normalIntensityProp = "u_normalIntensity"
    public static let _normalTextureProp = "u_normalTexture"
    public static let _normalSamplerProp = "u_normalSampler"

    public static let _emissiveColorProp = "u_emissiveColor"
    public static let _emissiveTextureProp = "u_emissiveTexture"
    public static let _emissiveSamplerProp = "u_emissiveSampler"

    private static let _alphaCutoffProp = "u_alphaCutoff"
    private var _alphaCutoff: Float = 0
    private var _isTransparent: Bool = false

    public var isTransparent: Bool {
        get {
            _isTransparent
        }
        set {
            _isTransparent = newValue
            if newValue {
                for pass in shader {
                    pass.setRenderQueueType(RenderQueueType.Transparent)
                }
            } else {
                for pass in shader {
                    pass.setRenderQueueType(_alphaCutoff > 0 ? RenderQueueType.AlphaTest : RenderQueueType.Opaque)
                }
            }
        }
    }

    public var alphaCutoff: Float {
        get {
            _alphaCutoff
        }
        set {
            _alphaCutoff = newValue
            shaderData.setData(BaseMaterial._alphaCutoffProp, newValue)
            if newValue > 0 {
                shaderData.enableMacro(NEED_ALPHA_CUTOFF.rawValue)
                for pass in shader {
                    pass.setRenderQueueType(_isTransparent ? RenderQueueType.Transparent : RenderQueueType.AlphaTest)
                }
            } else {
                shaderData.disableMacro(NEED_ALPHA_CUTOFF.rawValue)
                for pass in shader {
                    pass.setRenderQueueType(_isTransparent ? RenderQueueType.Transparent : RenderQueueType.Opaque)
                }
            }
        }
    }
    
    public override init(_ name: String = "") {
        super.init()
        shaderData.setData(BaseMaterial._alphaCutoffProp, 0)
    }
}
