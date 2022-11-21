//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

struct AnimationEventHandler {
    var event: AnimationEvent!
    var handlers: [(AnyObject) -> Void] = []
}
