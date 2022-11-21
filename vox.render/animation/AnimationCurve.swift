//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Store a collection of Keyframes that can be evaluated over time.
class AnimationCurve {
    /// All keys defined in the animation curve.
    var keys: [UnionInterpolableKeyframe] = []
    /// The interpolationType of the animation curve.
    var interpolation: InterpolationType!

    internal var _valueSize: Int = 0
    internal var _valueType: InterpolableValueType!

    private var _currentValue: InterpolableValue!
    private var _length: Float = 0
    private var _currentIndex: Int = 0

    /// Animation curve length in seconds.
    var length: Float {
        get {
            _length
        }
    }

    /// Add a new key to the curve.
    /// - Parameter key: The keyframe
    func addKey(_ key: UnionInterpolableKeyframe) {
        keys.append(key)

        switch key {
        case .FloatKeyframe(let value):
            let time = value.time
            if (time > _length) {
                _length = time
            }
            self._valueSize = 1
            self._valueType = InterpolableValueType.Float
            self._currentValue = .Float(0)

            break
        case .Vector2Keyframe(let value):
            let time = value.time
            if (time > _length) {
                _length = time
            }
            self._valueSize = 2
            self._valueType = InterpolableValueType.Vector2
            self._currentValue = .Vector2(Vector2())

            break
        case .Vector3Keyframe(let value):
            let time = value.time
            if (time > _length) {
                _length = time
            }
            self._valueSize = 3
            self._valueType = InterpolableValueType.Vector3
            self._currentValue = .Vector3(Vector3())

            break
        case .Vector4Keyframe(let value):
            let time = value.time
            if (time > _length) {
                _length = time
            }
            self._valueSize = 4
            self._valueType = InterpolableValueType.Vector4
            self._currentValue = .Vector4(Vector4())

            break
        case .QuaternionKeyframe(let value):
            let time = value.time
            if (time > _length) {
                _length = time
            }
            self._valueSize = 4
            self._valueType = InterpolableValueType.Quaternion
            self._currentValue = .Quaternion(Quaternion())

            break
        case .FloatArrayKeyframe(let value):
            let time = value.time
            if (time > _length) {
                _length = time
            }
            let size = value.value!.count
            self._valueSize = size
            self._valueType = InterpolableValueType.FloatArray
            self._currentValue = .FloatArray([Float](repeating: 0, count: size))

            break
        }
        keys.sort { a, b in
            return a.getTime() - b.getTime() > 0
        }
    }

    /// Evaluate the curve at time.
    /// - Parameter time: The time within the curve you want to evaluate
    func evaluate(_ time: Float) -> InterpolableValue {
        let length = self.keys.count

        // Compute curIndex and nextIndex.
        var curIndex = self._currentIndex

        // Reset loop.
        if (curIndex != -1 && time < keys[curIndex].getTime()) {
            curIndex = -1
        }

        var nextIndex = curIndex + 1
        while (nextIndex < length) {
            if (time < keys[nextIndex].getTime()) {
                break
            }
            curIndex += 1
            nextIndex += 1
        }
        self._currentIndex = curIndex
        // Evaluate value.
        let value: InterpolableValue
        if (curIndex == -1) {
            value = keys[0].getValue()
        } else if (nextIndex == length) {
            value = keys[curIndex].getValue()
        } else {
            // Time between first frame and end frame.
            let curFrameTime = keys[curIndex].getTime()
            let duration = keys[nextIndex].getTime() - curFrameTime
            let t = (time - curFrameTime) / duration
            let dur = duration

            switch (interpolation) {
            case .Linear:
                value = self._evaluateLinear(curIndex, nextIndex, t)
                break
            case .Step:
                value = self._evaluateStep(nextIndex)
                break
            case .CubicSpine, .Hermite:
                value = self._evaluateHermite(curIndex, nextIndex, t, dur)
            default:
                fatalError()
            }
        }
        return value
    }

    /// Removes the keyframe at index and inserts key.
    /// - Parameters:
    ///   - index: The index of the key to move
    ///   - key: The key to insert
    func moveKey(_ index: Int, _ key: UnionInterpolableKeyframe) {
        keys[index] = key
    }

    /// Removes a key.
    /// - Parameter index: The index of the key to remove
    func removeKey(_ index: Int) {
        keys.remove(at: index)
        let count = keys.count
        var newLength: Float = 0
        for i in 0..<count {
            let time = keys[i].getTime()
            if (time > length) {
                newLength = time
            }
        }
        _length = newLength
    }

    private func _evaluateLinear(_ frameIndex: Int, _ nextFrameIndex: Int, _ t: Float) -> InterpolableValue {
        switch (_valueType) {
        case .Float:
            return .Float(keys[frameIndex].getFloatValue() * (1 - t) + keys[nextFrameIndex].getFloatValue() * t)
        case .FloatArray:
            let value = keys[frameIndex].getFloatArrayValue()
            let nextValue = keys[nextFrameIndex].getFloatArrayValue()
            var array = [Float](repeating: 0, count: value.count)
            for i in 0..<value.count {
                array[i] = value[i] * (1 - t) + nextValue[i] * t
            }
            _currentValue = .FloatArray(array)
            return _currentValue
        case .Vector2:
            _currentValue = .Vector2(Vector2.lerp(left: keys[frameIndex].getVector2Value(),
                    right: keys[nextFrameIndex].getVector2Value(),
                    t: t))
            return _currentValue
        case .Vector3:
            _currentValue = .Vector3(Vector3.lerp(left: keys[frameIndex].getVector3Value(),
                    right: keys[nextFrameIndex].getVector3Value(),
                    t: t))
            return _currentValue
        case .Quaternion:
            _currentValue = .Quaternion(Quaternion.slerp(start: keys[frameIndex].getQuaternionValue(),
                    end: keys[nextFrameIndex].getQuaternionValue(),
                    t: t))
            return _currentValue
        default:
            fatalError()
        }
    }

    private func _evaluateStep(_ nextFrameIndex: Int) -> InterpolableValue {
        if (_valueSize == 1) {
            return keys[nextFrameIndex].getValue()
        } else {
            return keys[nextFrameIndex].getValue()
        }
    }

    private func _evaluateHermite(_ frameIndex: Int, _  nextFrameIndex: Int, _  t: Float, _  dur: Float) -> InterpolableValue {
        let curKey = keys[frameIndex]
        let nextKey = keys[nextFrameIndex]
        switch (_valueSize) {
        case 1:
            let t0 = curKey.getFloatOutTangentValue()
            let t1 = nextKey.getFloatInTangentValue()
            let p0 = curKey.getFloatValue()
            let p1 = nextKey.getFloatValue()
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                let t2 = t * t
                let t3 = t2 * t
                let a = 2.0 * t3 - 3.0 * t2 + 1.0
                let b = t3 - 2.0 * t2 + t
                let c = t3 - t2
                let d = -2.0 * t3 + 3.0 * t2
                return .Float(a * p0 + b * t0 * dur + c * t1 * dur + d * p1)
            } else {
                return .Float(curKey.getFloatValue())
            }

        case 2:
            let p0 = curKey.getVector2Value()
            let tan0 = curKey.getVector2OutTangentValue()
            let p1 = nextKey.getVector2Value()
            let tan1 = nextKey.getVector2InTangentValue()

            let t2 = t * t
            let t3 = t2 * t
            let a = 2.0 * t3 - 3.0 * t2 + 1.0
            let b = t3 - 2.0 * t2 + t
            let c = t3 - t2
            let d = -2.0 * t3 + 3.0 * t2

            var value = SIMD2<Float>()

            var t0 = tan0.x
            var t1 = tan1.x
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.x = a * p0.x + b * t0 * dur + c * t1 * dur + d * p1.x
            } else {
                value.x = p0.x
            }

            t0 = tan0.y
            t1 = tan1.y
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.y = a * p0.y + b * t0 * dur + c * t1 * dur + d * p1.y
            } else {
                value.y = p0.y
            }
            _currentValue = .Vector2(Vector2(value))
            return _currentValue

        case 3:
            let p0 = curKey.getVector3Value()
            let tan0 = curKey.getVector3OutTangentValue()
            let p1 = nextKey.getVector3Value()
            let tan1 = nextKey.getVector3InTangentValue()

            let t2 = t * t
            let t3 = t2 * t
            let a = 2.0 * t3 - 3.0 * t2 + 1.0
            let b = t3 - 2.0 * t2 + t
            let c = t3 - t2
            let d = -2.0 * t3 + 3.0 * t2

            var value = SIMD3<Float>()

            var t0 = tan0.x
            var t1 = tan1.x
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.x = a * p0.x + b * t0 * dur + c * t1 * dur + d * p1.x
            } else {
                value.x = p0.x
            }

            t0 = tan0.y
            t1 = tan1.y
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.y = a * p0.y + b * t0 * dur + c * t1 * dur + d * p1.y
            } else {
                value.y = p0.y
            }

            t0 = tan0.z
            t1 = tan1.z
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.z = a * p0.z + b * t0 * dur + c * t1 * dur + d * p1.z
            } else {
                value.z = p0.z
            }

            _currentValue = .Vector3(Vector3(value))
            return _currentValue

        case 4:
            let p0 = curKey.getQuaternionValue()
            let tan0 = curKey.getQuaternionOutTangentValue()
            let p1 = nextKey.getQuaternionValue()
            let tan1 = nextKey.getQuaternionInTangentValue()

            let t2 = t * t
            let t3 = t2 * t
            let a = 2.0 * t3 - 3.0 * t2 + 1.0
            let b = t3 - 2.0 * t2 + t
            let c = t3 - t2
            let d = -2.0 * t3 + 3.0 * t2

            var value = simd_quatf()

            var t0 = tan0.x
            var t1 = tan1.x
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.imag.x = a * p0.x + b * t0 * dur + c * t1 * dur + d * p1.x
            } else {
                value.imag.x = p0.x
            }

            t0 = tan0.y
            t1 = tan1.y
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.imag.y = a * p0.y + b * t0 * dur + c * t1 * dur + d * p1.y
            } else {
                value.imag.y = p0.y
            }

            t0 = tan0.z
            t1 = tan1.z
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.imag.z = a * p0.z + b * t0 * dur + c * t1 * dur + d * p1.z
            } else {
                value.imag.z = p0.z
            }

            t0 = tan0.w
            t1 = tan1.w
            if (t0.isLessThanOrEqualTo(Float.greatestFiniteMagnitude) && t1.isLessThanOrEqualTo(Float.greatestFiniteMagnitude)) {
                value.real = a * p0.w + b * t0 * dur + c * t1 * dur + d * p1.w
            } else {
                value.real = p0.w
            }

            _currentValue = .Quaternion(Quaternion(value))
            return _currentValue
        default:
            fatalError()
        }
    }
}
