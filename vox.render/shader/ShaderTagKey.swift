//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Shader tag key.
public struct ShaderTagKey {
    private static var _nameCounter: Int = 0;
    private static var _nameMap: [String : ShaderTagKey] = [:]
    
    /// Get shader property by name.
    /// - Parameter name: Name of the shader property
    /// - Returns: Shader property
    static func getByName(_ name: String) -> ShaderTagKey {
        if let key = ShaderTagKey._nameMap[name] {
            return key
        } else {
            let key = ShaderTagKey(name: name)
            ShaderTagKey._nameMap[name] = key
            return key
        }
    }
    
    /// Shader tag property name.
    public private(set) var name: String;
    
    var _uniqueId: Int
    
    private init(name: String) {
        self.name = name;
        _uniqueId = ShaderTagKey._nameCounter + 1
        ShaderTagKey._nameCounter = _uniqueId
    }
}
