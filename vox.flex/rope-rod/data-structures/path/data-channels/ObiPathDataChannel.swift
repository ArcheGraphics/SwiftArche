//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IObiPathDataChannel {
    var Count: Int { get }
    var Dirty: Bool { get }
    func Clean()
    func RemoveAt(index: Int)
}

public class ObiPathDataChannel<T, Interpolator: ObiInterpolator>: IObiPathDataChannel {
    public typealias U = Interpolator.T
    var interpolator: Interpolator
    var dirty = false
    public var data: [T] = []

    public var Count: Int {
        data.count
    }

    public var Dirty: Bool {
        dirty
    }

    public func Clean() {
        dirty = false
    }

    public func RemoveAt(index: Int) {
        data.remove(at: index)
        dirty = true
    }

    public init(interpolator: Interpolator) {
        self.interpolator = interpolator
    }

    subscript(i: Int) -> T {
        get {
            data[i]
        }
        set {
            data[i] = newValue
            dirty = true
        }
    }

    public func Evaluate(v0: U, v1: U, v2: U, v3: U, mu: Float) -> U {
        return interpolator.Evaluate(v0: v0, v1: v1, v2: v2, v3: v3, mu: mu)
    }

    public func EvaluateFirstDerivative(v0: U, v1: U, v2: U, v3: U, mu: Float) -> U {
        return interpolator.EvaluateFirstDerivative(v0: v0, v1: v1, v2: v2, v3: v3, mu: mu)
    }

    public func EvaluateSecondDerivative(v0: U, v1: U, v2: U, v3: U, mu: Float) -> U {
        return interpolator.EvaluateSecondDerivative(v0: v0, v1: v1, v2: v2, v3: v3, mu: mu)
    }

    public func GetSpanCount(closed _: Bool) -> Int {
        0
    }

    public func GetSpanControlPointAtMu(closed _: Bool, mu _: Float, spanMu _: inout Float) -> Int {
        0
    }
}
