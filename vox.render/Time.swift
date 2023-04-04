//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Tools for calculating the time per frame.
public enum Time {
    private static var _deltaTime: Float = 0.0001
    private static var _startTime = Date()
    private static var _lastTickTime = Date()

    /// Current Time
    public static var nowTime: Date {
        Date()
    }

    /// Time between two ticks
    public static var deltaTime: Float {
        _deltaTime
    }

    /// The time at the beginning of this frame
    public static var time: Float {
        Float(_lastTickTime.timeIntervalSince1970)
    }

    /// Scaled delta time.
    public static var timeScale: Float = 1.0

    /// Unscaled delta time.
    static var unscaledDeltaTime: Float {
        _deltaTime / timeScale
    }

    /// The elapsed time, after the clock is initialized.
    static var timeSinceStartup: Float {
        Float(Date().timeIntervalSince(_startTime))
    }

    /// Call every frame, update delta time and other data.
    public static func tick() {
        _deltaTime = Float(Date.now.timeIntervalSince(_lastTickTime)) * timeScale
        if _deltaTime < 0 {
            fatalError()
        }
        _lastTickTime = Date.now
    }

    public static func reset() {
        _lastTickTime = Date()
    }
}
