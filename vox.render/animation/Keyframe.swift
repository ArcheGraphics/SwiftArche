//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Keyframe.
/// @typeParam V - Type of Keyframe value
protocol Keyframe {
    associatedtype V
    /// The time of the Keyframe.
    var time: Float { get set }
    /// The value of the Keyframe.
    var value: V? { get set }
}

/// InterpolableKeyframe.
/// @typeParam T - Type of Tangent value
/// @typeParam V - Type of Keyframe value
class InterpolableKeyframe<T, V>: Keyframe {
    var time: Float = 0.0
    var value: V?

    /// Sets the incoming tangent for this key. The incoming tangent affects the slope of the curve from the previous key to this key.
    var inTangent: T?
    /// Sets the outgoing tangent for this key. The outgoing tangent affects the slope of the curve from this key to the next key.
    var outTangent: T?
}

typealias FloatKeyframe = InterpolableKeyframe<Float, Float>
typealias FloatArrayKeyframe = InterpolableKeyframe<[Float], [Float]>
typealias Vector2Keyframe = InterpolableKeyframe<Vector2, Vector2>
typealias Vector3Keyframe = InterpolableKeyframe<Vector3, Vector3>
typealias Vector4Keyframe = InterpolableKeyframe<Vector4, Vector4>
typealias QuaternionKeyframe = InterpolableKeyframe<Vector4, Quaternion>

enum UnionInterpolableKeyframe {
    case FloatKeyframe(FloatKeyframe)
    case FloatArrayKeyframe(FloatArrayKeyframe)
    case Vector2Keyframe(Vector2Keyframe)
    case Vector3Keyframe(Vector3Keyframe)
    case Vector4Keyframe(Vector4Keyframe)
    case QuaternionKeyframe(QuaternionKeyframe)

    func getTime() -> Float {
        switch self {
        case .FloatKeyframe(let value):
            return value.time
        case .Vector2Keyframe(let value):
            return value.time
        case .Vector3Keyframe(let value):
            return value.time
        case .Vector4Keyframe(let value):
            return value.time
        case .QuaternionKeyframe(let value):
            return value.time
        case .FloatArrayKeyframe(let value):
            return value.time
        }
    }

    func getValue() -> InterpolableValue {
        switch self {
        case .FloatKeyframe(let value):
            return .Float(value.value!)
        case .Vector2Keyframe(let value):
            return .Vector2(value.value!)
        case .Vector3Keyframe(let value):
            return .Vector3(value.value!)
        case .Vector4Keyframe(let value):
            return .Vector4(value.value!)
        case .QuaternionKeyframe(let value):
            return .Quaternion(value.value!)
        case .FloatArrayKeyframe(let value):
            return .FloatArray(value.value!)
        }
    }

    func getFloatValue() -> Float {
        switch self {
        case .FloatKeyframe(let value):
            return value.value!
        default:
            fatalError()
        }
    }

    func getFloatInTangentValue() -> Float {
        switch self {
        case .FloatKeyframe(let value):
            return value.inTangent!
        default:
            fatalError()
        }
    }

    func getFloatOutTangentValue() -> Float {
        switch self {
        case .FloatKeyframe(let value):
            return value.outTangent!
        default:
            fatalError()
        }
    }

    func getVector2Value() -> Vector2 {
        switch self {
        case .Vector2Keyframe(let value):
            return value.value!
        default:
            fatalError()
        }
    }

    func getVector2InTangentValue() -> Vector2 {
        switch self {
        case .Vector2Keyframe(let value):
            return value.inTangent!
        default:
            fatalError()
        }
    }

    func getVector2OutTangentValue() -> Vector2 {
        switch self {
        case .Vector2Keyframe(let value):
            return value.outTangent!
        default:
            fatalError()
        }
    }

    func getVector3Value() -> Vector3 {
        switch self {
        case .Vector3Keyframe(let value):
            return value.value!
        default:
            fatalError()
        }
    }

    func getVector3InTangentValue() -> Vector3 {
        switch self {
        case .Vector3Keyframe(let value):
            return value.inTangent!
        default:
            fatalError()
        }
    }

    func getVector3OutTangentValue() -> Vector3 {
        switch self {
        case .Vector3Keyframe(let value):
            return value.outTangent!
        default:
            fatalError()
        }
    }

    func getVector4Value() -> Vector4 {
        switch self {
        case .Vector4Keyframe(let value):
            return value.value!
        default:
            fatalError()
        }
    }

    func getVector4InTangentValue() -> Vector4 {
        switch self {
        case .Vector4Keyframe(let value):
            return value.inTangent!
        default:
            fatalError()
        }
    }

    func getVector4OutTangentValue() -> Vector4 {
        switch self {
        case .Vector4Keyframe(let value):
            return value.outTangent!
        default:
            fatalError()
        }
    }

    func getQuaternionValue() -> Quaternion {
        switch self {
        case .QuaternionKeyframe(let value):
            return value.value!
        default:
            fatalError()
        }
    }

    func getQuaternionInTangentValue() -> Vector4 {
        switch self {
        case .QuaternionKeyframe(let value):
            return value.inTangent!
        default:
            fatalError()
        }
    }

    func getQuaternionOutTangentValue() -> Vector4 {
        switch self {
        case .QuaternionKeyframe(let value):
            return value.outTangent!
        default:
            fatalError()
        }
    }

    func getFloatArrayValue() -> [Float] {
        switch self {
        case .FloatArrayKeyframe(let value):
            return value.value!
        default:
            fatalError()
        }
    }
}

enum InterpolableValue {
    case Float(Float)
    case Vector2(Vector2)
    case Vector3(Vector3)
    case Vector4(Vector4)
    case Quaternion(Quaternion)
    case FloatArray([Float])

    func getFloat() -> Float {
        switch self {
        case .Float(let value):
            return value
        default:
            fatalError()
        }
    }

    func getVector2() -> Vector2 {
        switch self {
        case .Vector2(let value):
            return value
        default:
            fatalError()
        }
    }

    func getVector3() -> Vector3 {
        switch self {
        case .Vector3(let value):
            return value
        default:
            fatalError()
        }
    }

    func getVector4() -> Vector4 {
        switch self {
        case .Vector4(let value):
            return value
        default:
            fatalError()
        }
    }

    func getQuaternion() -> Quaternion {
        switch self {
        case .Quaternion(let value):
            return value
        default:
            fatalError()
        }
    }

    func getFloatArray() -> [Float] {
        switch self {
        case .FloatArray(let value):
            return value
        default:
            fatalError()
        }
    }
}
