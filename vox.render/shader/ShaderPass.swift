//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Shader pass
public struct ShaderPass {
    internal var _library: MTLLibrary!
    internal var _shaders: [String]
    
    public private(set) var tagsMap: [String : ShaderProperty] = [:]
    
    public init(_ library: MTLLibrary, _ computeShader: String) {
        _shaders = [computeShader]
        _library = library
    }
    
    public init(_ library: MTLLibrary, _ vertexSource: String, _ fragmentSource: String?,
                tags: [String: ShaderProperty] = [ShaderTagKey.pipelineStage.rawValue : PipelineStage.Forward]) {
        if fragmentSource == nil {
            _shaders = [vertexSource]
        } else {
            _shaders = [vertexSource, fragmentSource!]
        }

        _library = library
        tagsMap = tags
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
            print("Unexpected error: \(error).")
            return nil
        }
    }

    private func makeFunctionConstants(_ macroInfo: ShaderMacroCollection) -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        macroInfo._value.forEach { info in
            if info.value.1 == .bool {
                var property: Bool
                if info.value.0 == 1 {
                    property = true
                } else {
                    property = false
                }
                functionConstants.setConstantValue(&property, type: .bool, index: Int(info.key))
            } else {
                var property = info.value.0
                functionConstants.setConstantValue(&property, type: info.value.1, index: Int(info.key))
            }
        }
        return functionConstants
    }
}
