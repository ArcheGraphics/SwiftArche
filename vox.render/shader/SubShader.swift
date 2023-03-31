//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Sub shader.
public class SubShader: ShaderPart {
    public private(set) var passes: [ShaderPass]
    
    /// Create a sub shader.
    init(name: String, passes: [ShaderPass], tags: [String : ShaderProperty]?) {
        self.passes = passes
        super.init()
        
        if let tags {
            for tag in tags {
                setTag(by: tag.key, with: tag.value)
            }
        }
    }
}
