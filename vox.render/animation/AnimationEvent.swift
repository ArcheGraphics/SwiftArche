//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// AnimationEvent lets you call a script function similar to SendMessage as part of playing back an animation.
public class AnimationEvent {
    /// The time when the event be triggered.
    public var time: Float = 0
    /// The name of the method called in the script.
    public var functionName: String = ""
    /// The parameter that is stored in the event and will be sent to the function.
    public var parameter: AnyObject?
}
