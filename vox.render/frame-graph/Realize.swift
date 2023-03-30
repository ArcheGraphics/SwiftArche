//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public protocol ResourceRealize {
    associatedtype actual_type
    func realize(with heap: MTLHeap?) -> actual_type?
    func derealize(resource: actual_type)
    var size: Int { get }
}
