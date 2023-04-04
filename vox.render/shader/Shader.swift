//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Shader for rendering.
public struct Shader {
    public private(set) var subShaders: [SubShader]

    /// Create a shader.
    /// - Parameters:
    ///   - name: Name of the shader
    ///   - vertexSource: Vertex source code
    ///   - fragmentSource: Fragment source code
    /// - Returns: Shader
    public static func create(in library: MTLLibrary,
                              vertexSource: String, fragmentSource: String?) -> Shader
    {
        let shaderPass = ShaderPass(library, vertexSource, fragmentSource)
        return Shader(subShaders: [SubShader(name: "Default", passes: [shaderPass])])
    }

    /// Create a shader.
    /// - Parameters:
    ///   - name: Name of the shader
    ///   - computeSource: Vertex source code
    /// - Returns: Shader
    public static func create(in library: MTLLibrary, computeSource: String) -> Shader {
        let shaderPass = ShaderPass(library, computeSource)
        return Shader(subShaders: [SubShader(name: "Default", passes: [shaderPass])])
    }

    /// Create a shader.
    /// - Parameters:
    ///   - name: Name of the shader
    ///   - shaderPasses: Shader passes
    /// - Returns: Shader
    public static func create(shaderPasses: [ShaderPass]) -> Shader {
        return Shader(subShaders: [SubShader(name: "Default", passes: shaderPasses)])
    }

    /// Create a shader.
    /// - Parameters:
    ///   - name: Name of the shader
    ///   - subShaders: Sub shaders
    /// - Returns: Shader
    public static func create(subShaders: [SubShader]) -> Shader {
        return Shader(subShaders: subShaders)
    }

    private init(subShaders: [SubShader]) {
        self.subShaders = subShaders
    }
}
