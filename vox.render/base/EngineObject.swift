//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

open class EngineObject: NSObject, Identifiable {
    private static var _instanceIdCounter: Int = 0

    /// Engine unique id.
    public let id: Int

    public override init() {
        EngineObject._instanceIdCounter += 1
        id = EngineObject._instanceIdCounter
    }
}
