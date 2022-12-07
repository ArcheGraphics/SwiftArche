//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Stores keyframe based animations.
public class AnimationClip {
    var _curveBindings: [AnimationClipCurveBindingBase] = []
    private var _length: Float = 0
    private var _events: [AnimationEvent] = []

    /// The AnimationClip's name
    public let name: String

    /// Animation events for this animation clip.
    public var events: [AnimationEvent] {
        get {
            _events
        }
    }

    /// Animation curve bindings for this animation clip.
    public var curveBindings: [AnimationClipCurveBindingBase] {
        get {
            _curveBindings
        }
    }

    /// Animation length in seconds.
    public var length: Float {
        get {
            _length
        }
    }

    init(_ name: String) {
        self.name = name
    }

    /// Adds an animation event to the clip.
    /// - Parameter event: The animation event
    public func addEvent(_ event: AnimationEvent) {
        _events.append(event)
        _events.sort { a, b in
            a.time - b.time < 0
        }
    }

    /// Clears all events from the clip.
    public func clearEvents() {
        _events = []
    }

    /// Add curve binding for the clip.
    /// - Parameters:
    ///   - relativePath: Path to the game object this curve applies to. The relativePath is formatted similar to a pathname, e.g. "/root/spine/leftArm"
    ///   - type: The class type of the component that is animated
    ///   - propertyName: The name to the property being animated
    ///   - curve: The animation curve
    public func addCurveBinding<T: Component,
                               V: KeyframeValueType,
                               Calculator: IAnimationCurveCalculator>(_ relativePath: String,
                                                                      _ type: T.Type,
                                                                      _ propertyName: AnimationProperty,
                                                                      _ curve: AnimationCurve<V, Calculator>) where Calculator.V == V {
        let curveBinding = AnimationClipCurveBinding<V, Calculator>()
        curveBinding.relativePath = relativePath
        curveBinding.type = type
        curveBinding.property = propertyName
        curveBinding.curve = curve
        if (curve.length > _length) {
            _length = curve.length
        }
        _curveBindings.append(curveBinding)
    }

    /// Clears all curve bindings from the clip.
    public func clearCurveBindings() {
        _curveBindings = []
        _length = 0
    }
}
