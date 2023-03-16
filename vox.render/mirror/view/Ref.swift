//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class Ref<T> {
    public var value: T {
        didSet {
            didSet(value)
        }
    }

    var didSet: (T) -> Void = { _ in
    }

    init(value: T) {
        self.value = value
    }
}
