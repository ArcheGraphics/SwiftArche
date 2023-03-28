//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

protocol ResourceRealize {
    associatedtype actual_type
    func realize() -> actual_type?
}

extension MTLTextureDescriptor: ResourceRealize {
    typealias actual_type = MTLTexture

    func realize() -> actual_type? {
        Engine.device.makeTexture(descriptor: self)
    }
}
