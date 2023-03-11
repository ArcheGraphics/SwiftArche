//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class AnimationClip: AnimationState {
    /// Playback speed, can be negative in order to play the animation backward.
    public var playbackSpeed: Float {
        get {
            (_nativeState as! CAnimationClip).playback_speed
        }
        set {
            (_nativeState as! CAnimationClip).playback_speed = newValue
        }
    }

    /// Animation play mode state: play/pause.
    public var play: Bool {
        get {
            (_nativeState as! CAnimationClip).play
        }
        set {
            (_nativeState as! CAnimationClip).play = newValue
        }
    }

    /// Animation loop mode.
    public var loop: Bool {
        get {
            (_nativeState as! CAnimationClip).loop
        }
        set {
            (_nativeState as! CAnimationClip).loop = newValue
        }
    }

    /// Gets animation current time.
    public var timeRatio: Float {
        get {
            (_nativeState as! CAnimationClip).timeRatio()
        }
        set {
            (_nativeState as! CAnimationClip).setTimeRatio(newValue)
        }
    }

    /// Gets animation time ratio of last update. Useful when the range between
    /// previous and current frame needs to pe processed.
    public var previousTimeRatio: Float {
        get {
            (_nativeState as! CAnimationClip).previousTimeRatio()
        }
    }

    public init(filename: String) {
        super.init()
        _nativeState = CAnimationClip(filename: filename)
    }

    /// Resets all parameters to their default value.
    public func reset() {
        (_nativeState as! CAnimationClip).reset()
    }

    public func loadAnimation(_ filename: String) {
        (_nativeState as! CAnimationClip).loadAnimation(filename)
    }
}
