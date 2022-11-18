//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Shader pass
public class ShaderPass {
    internal var _library: MTLLibrary
    internal var _shaders: [String]
    internal var _renderState: RenderState? = nil

    public var renderState: RenderState? {
        get {
            _renderState
        }
    }

    public init(_ library: MTLLibrary, _ computeShader: String) {
        _shaders = [computeShader]
        _library = library
    }

    public init(_ library: MTLLibrary, _ vertexSource: String, _ fragmentSource: String?) {
        if fragmentSource == nil {
            _shaders = [vertexSource]
        } else {
            _shaders = [vertexSource, fragmentSource!]
        }
        _library = library
        _renderState = RenderState()
        setBlendMode(.Normal)
    }

    /// Set the blend mode of shader pass render state.
    /// - Parameter blendMode: Blend mode
    public func setBlendMode(_ blendMode: BlendMode) {
        let target = _renderState!.blendState.targetBlendState
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
    /// - Parameter renderFace: Render face
    public func setRenderFace(_ renderFace: RenderFace) {
        switch (renderFace) {
        case RenderFace.Front:
            _renderState!.rasterState.cullMode = .back
            break
        case RenderFace.Back:
            _renderState!.rasterState.cullMode = .front
            break
        case RenderFace.Double:
            _renderState!.rasterState.cullMode = .none
            break
        }
    }

    /// Set if is transparent of the shader pass render state.
    /// - Parameter type: RenderQueueType
    func setRenderQueueType(_ type: RenderQueueType) {
        _renderState!.renderQueueType = RenderQueueType.Transparent
        switch type {
        case RenderQueueType.Transparent:
            _renderState!.blendState.targetBlendState.enabled = true
            _renderState!.depthState.writeEnabled = false
            break
        case RenderQueueType.Opaque, RenderQueueType.AlphaTest:
            _renderState!.blendState.targetBlendState.enabled = false
            _renderState!.depthState.writeEnabled = true
        }
    }

    /// init and link program with shader.
    /// - Parameters:
    ///   - source: shader name
    ///   - macroInfo: macros
    func createProgram(_ source: String,
                       _ macroInfo: ShaderMacroCollection) -> MTLFunction? {
        let functionConstants = makeFunctionConstants(macroInfo)

        do {
            return try _library.makeFunction(name: source, constantValues: functionConstants)
        } catch {
            return nil
        }
    }

    private func makeFunctionConstants(_ macroInfo: ShaderMacroCollection) -> MTLFunctionConstantValues {
        let functionConstants = ShaderMacroCollection.defaultFunctionConstant
        macroInfo._value.forEach { info in
            if info.value.1 == .bool {
                var property: Bool
                if info.value.0 == 1 {
                    property = true
                } else {
                    property = false
                }
                functionConstants.setConstantValue(&property, type: .bool, index: Int(info.key.rawValue))
            } else {
                var property = info.value.0
                functionConstants.setConstantValue(&property, type: info.value.1, index: Int(info.key.rawValue))
            }
        }
        return functionConstants
    }
}
