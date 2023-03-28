//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public protocol ResourceRealize {
    associatedtype actual_type
    func realize() -> actual_type?
}

public protocol RenderTaskDataType: AnyObject {
    init()
}

//extension MTLTextureDescriptor: ResourceRealize {
//    public typealias actual_type = MTLTexture
//
//    public func realize() -> actual_type? {
//        Engine.device.makeTexture(descriptor: self)
//    }
//}
