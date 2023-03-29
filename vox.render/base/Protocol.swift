//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public protocol EmptyClassType: AnyObject {
    init()
}

public class EmptyClass: EmptyClassType {
    required public init() {}
}
