//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Animation event type.
public enum AnimationEventType: Int {
    /// Triggered when the animation over if the wrapMode === WrapMode.ONCE
    case Finished = 0
    /// Triggered when the animation over if the wrapMode === WrapMode.LOOP
    case LoopEnd = 1
    /// Triggered when the animation plays to the frame
    case FrameEvent = 2
}
