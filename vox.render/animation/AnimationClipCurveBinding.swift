//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Associate AnimationCurve and the Entity
public class AnimationClipCurveBinding<V: KeyframeValueType> {
    /// Path to the entity this curve applies to. The relativePath is formatted similar to a pathname,
    /// e.g. "root/spine/leftArm". If relativePath is empty it refers to the entity the animation clip is attached to.
    var relativePath: String!
    /// The name or path to the property being animated.
    var property: String!
    /// The animation curve.
    var curve: AnimationCurve<V>!
}