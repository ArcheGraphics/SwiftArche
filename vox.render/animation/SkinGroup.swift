//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class SkinGroup {
    private var _nativeGroup = CSkinGroup()
    
    public var count: Int {
        Int(_nativeGroup.count())
    }
    
    public init(_ url: URL) {
        loadSkin(url)
    }
    
    public func loadSkin(_ url: URL) {
        _nativeGroup.loadSkin(url.path(percentEncoded: false))
    }
}
