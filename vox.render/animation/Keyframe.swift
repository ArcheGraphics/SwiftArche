//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public protocol KeyframeValueType {
    associatedtype TangentType
}

extension Float: KeyframeValueType {
    public typealias TangentType = Float
}

extension Vector2: KeyframeValueType {
    public typealias TangentType = Vector2
}

extension Vector3: KeyframeValueType {
    public typealias TangentType = Vector3
}

extension Vector4: KeyframeValueType {
    public typealias TangentType = Vector4
}

extension Color: KeyframeValueType {
    public typealias TangentType = Vector4
}

extension Quaternion: KeyframeValueType {
    public typealias TangentType = Vector4
}

extension Array<Float>: KeyframeValueType {
    public typealias TangentType = Array<Float>
}

public class Keyframe<T: KeyframeValueType> {
    /// The time of the Keyframe.
    var time: Float!
    /// The value of the Keyframe.
    var value: T!
    /// Sets the incoming tangent for this key.
    // The incoming tangent affects the slope of the curve from the previous key to this key.
    var inTangent: T.TangentType?
    /// Sets the outgoing tangent for this key.
    // The outgoing tangent affects the slope of the curve from this key to the next key.
    var outTangent: T.TangentType?
}