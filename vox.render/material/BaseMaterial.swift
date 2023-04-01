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

    public override var shader: Shader {
        get {
            _shader
        }
        set {
            _shader = newValue
            let lastStatesCount = renderStates.count

            var maxPassCount = 0
            let subShaders = shader.subShaders
            for i in 0..<subShaders.count {
                maxPassCount = max(subShaders[i].passes.count, maxPassCount)
            }

            if (lastStatesCount < maxPassCount) {
                for i in lastStatesCount..<maxPassCount {
                    renderStates.append(RenderState())
                    setBlendMode(at: i, BlendMode.Normal)
                }
            } else {
                renderStates = renderStates.dropLast(renderStates.count - maxPassCount)
            }
        }
    }

    public var isTransparent: Bool {
        get {
            _isTransparent
        }
        set {
            _isTransparent = newValue
            if newValue {
                for i in 0..<renderStates.count {
                    setRenderQueueType(at: i, RenderQueueType.Transparent)
                }
            } else {
                for i in 0..<renderStates.count {
                    setRenderQueueType(at: i, _alphaCutoff > 0 ? RenderQueueType.AlphaTest : RenderQueueType.Opaque)
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
                for i in 0..<renderStates.count {
                    setRenderQueueType(at: i, _isTransparent ? RenderQueueType.Transparent : RenderQueueType.AlphaTest)
                }
            } else {
                shaderData.disableMacro(NEED_ALPHA_CUTOFF.rawValue)
                for i in 0..<renderStates.count {
                    setRenderQueueType(at: i, _isTransparent ? RenderQueueType.Transparent : RenderQueueType.Opaque)
                }
            }
        }
    }

    public override init(shader: Shader, _ name: String = "") {
        super.init(shader: shader)
        shaderData.setData(BaseMaterial._alphaCutoffProp, 0)
    }

    /// Set if is transparent of the shader pass render state.
    /// - Parameters:
    ///   - passIndex: Shader pass index
    ///   - type: RenderQueueType
    func setRenderQueueType(at passIndex: Int, _ type: RenderQueueType) {
        assert(renderStates.count > passIndex)
        let renderState = renderStates[passIndex]
        renderState.renderQueueType = type
        switch type {
        case RenderQueueType.Transparent:
            renderState.blendState.targetBlendState.enabled = true
            renderState.depthState.writeEnabled = false
            break
        case RenderQueueType.Opaque, RenderQueueType.AlphaTest:
            renderState.blendState.targetBlendState.enabled = false
            renderState.depthState.writeEnabled = true
        }
    }

    /// Set the blend mode of shader pass render state.
    ///   - passIndex: Shader pass index
    /// - Parameter blendMode: Blend mode
    public func setBlendMode(at passIndex: Int, _ blendMode: BlendMode) {
        assert(renderStates.count > passIndex)
        let target = renderStates[passIndex].blendState.targetBlendState
        switch (blendMode) {
        case BlendMode.Normal:
            target.sourceColorBlendFactor = .sourceAlpha
            target.destinationColorBlendFactor = .oneMinusSourceAlpha
            target.sourceAlphaBlendFactor = .one
            target.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            target.colorBlendOperation = .add
            target.alphaBlendOperation = .add
            break
        case BlendMode.Additive:
            target.sourceColorBlendFactor = .sourceAlpha
            target.destinationColorBlendFactor = .one
            target.sourceAlphaBlendFactor = .one
            target.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            target.colorBlendOperation = .add
            target.alphaBlendOperation = .add
            break
        }
    }

    /// Set the render face of shader pass render state.
    ///   - passIndex: Shader pass index
    /// - Parameter renderFace: Render face
    public func setRenderFace(at passIndex: Int, _ renderFace: RenderFace) {
        assert(renderStates.count > passIndex)
        switch (renderFace) {
        case RenderFace.Front:
            renderStates[passIndex].rasterState.cullMode = .back
            break
        case RenderFace.Back:
            renderStates[passIndex].rasterState.cullMode = .front
            break
        case RenderFace.Double:
            renderStates[passIndex].rasterState.cullMode = .none
            break
        }
    }
}
