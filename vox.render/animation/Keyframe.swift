//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

protocol KeyframeValueType {
    associatedtype TangentType

    init()
}

extension Bool: KeyframeValueType {
    typealias TangentType = Bool
}

extension Float: KeyframeValueType {
    typealias TangentType = Float
}

extension Vector2: KeyframeValueType {
    typealias TangentType = Vector2
}

extension Vector3: KeyframeValueType {
    typealias TangentType = Vector3
}

extension Vector4: KeyframeValueType {
    typealias TangentType = Vector4
}

extension Color: KeyframeValueType {
    typealias TangentType = Vector4
}

extension Quaternion: KeyframeValueType {
    typealias TangentType = Vector4
}

extension Array<Float>: KeyframeValueType {
    typealias TangentType = Array<Float>
}

class Keyframe<V: KeyframeValueType> {
    /// The time of the Keyframe.
    var time: Float = 0.0
    /// The value of the Keyframe.
    var value: V!

    /// Sets the incoming tangent for this key. The incoming tangent affects the slope of the curve from the previous key to this key.
    var inTangent: V.TangentType?
    /// Sets the outgoing tangent for this key. The outgoing tangent affects the slope of the curve from this key to the next key.
    var outTangent: V.TangentType?
}