//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public enum ShaderProperty {
    case Int(Int)
    case Bool(Bool)
    case String(String)
}

/// Base class for shader structure.
public class ShaderPart {
    private var _tagsMap: [Int : ShaderProperty] = [:]
    
    /// Set tag by key name.
    /// - Parameters:
    ///   - by: Key name of the tag
    ///   - with: Tag value
    public func setTag(by keyName: String, with value: ShaderProperty) {
        setTag(by: ShaderTagKey.getByName(keyName), with: value)
    }
    
    /// Set tag.
    /// - Parameters:
    ///   - key: Key of the tag
    ///   - value: Tag value
    public func setTag(by key: ShaderTagKey, with value: ShaderProperty) {
        if _tagsMap[key._uniqueId] != nil {
            logger.warning("The value of tag named \(key.name) is being replaced.")
        }
        _tagsMap[key._uniqueId] = value
    }
    
    /// Delete a tag by key name.
    /// - Parameter KeyName: Key name of the tag
    public func deleteTag(for KeyName: String) {
        deleteTag(for: ShaderTagKey.getByName(KeyName))
    }

    /// Delete a tag by key.
    /// - Parameter key: Key of the tag
    public func deleteTag(for key: ShaderTagKey) {
        _tagsMap.removeValue(forKey: key._uniqueId)
    }
    
    /// Get tag by key name.
    /// - Parameter keyName: Key name of the tag
    /// - Returns: Tag value
    public func getTagValue(for keyName: String) -> ShaderProperty? {
        getTagValue(for: ShaderTagKey.getByName(keyName))
    }

    /// Get tag value by key.
    /// - Parameter key: Key of the tag
    /// - Returns: Tag value
    public func getTagValue(for key: ShaderTagKey) -> ShaderProperty? {
        _tagsMap[key._uniqueId]
    }
}
