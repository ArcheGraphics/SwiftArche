//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Tools for calculating the time per frame.
public class Time {
    private var _deltaTime: Float
    private var _startTime: Date
    private var _lastTickTime: Date

    /// Current Time
    public var nowTime: Date {
        get {
            Date()
        }
    }

    /// Time between two ticks
    public var deltaTime: Float {
        get {
            _deltaTime
        }
    }

    /// Scaled delta time.
    public var timeScale: Float

    /// Unscaled delta time.
    var unscaledDeltaTime: Float {
        get {
            _deltaTime / timeScale
        }
    }

    /// The elapsed time, after the clock is initialized.
    var timeSinceStartup: Float {
        get {
            Float(Date().timeIntervalSince(_startTime))
        }
    }

    public init() {
        timeScale = 1.0
        _deltaTime = 0.0001

        let now = Date()
        _startTime = now
        _lastTickTime = now
    }

    /// Call every frame, update delta time and other data.
    public func tick() {
        let now = Date()
        _deltaTime = Float(now.timeIntervalSince(_lastTickTime)) * timeScale
        _lastTickTime = now
    }

    public func reset() {
        _lastTickTime = Date()
    }
}