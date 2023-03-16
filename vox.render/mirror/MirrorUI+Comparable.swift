//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

extension MirrorUI where T: Comparable {
    public var min: T? {
        set {
            properties.set(min: newValue)
            updateMinMaxValueModifier()
        }
        get {
            properties.getMin()
        }
    }

    public var max: T? {
        set {
            properties.set(max: newValue)
            updateMinMaxValueModifier()
        }
        get {
            properties.getMax()
        }
    }

    public var range: ClosedRange<T>? {
        set {
            min = newValue?.lowerBound
            max = newValue?.upperBound
        }
        get {
            guard let min = self.min, let max = self.max else {
                return nil
            }
            return min...max
        }
    }

    public convenience init(wrappedValue: T, min: T? = nil, max: T? = nil) {
        self.init(wrappedValue: wrappedValue)
        self.min = min
        self.max = max
    }

    public convenience init(wrappedValue: T, range: ClosedRange<T>) {
        self.init(wrappedValue: wrappedValue)
        self.range = range
    }

    private func updateMinMaxValueModifier() {

        let minValue = self.min
        let maxValue = self.max

        ref.set(valueModifier: { value in
            var result = value
            if let minValue = minValue {
                result = Swift.max(minValue, result)
            }
            if let maxValue = maxValue {
                result = Swift.min(maxValue, result)
            }
            return result

        }, forKey: "MinMax")
    }

}

extension ControlProperties {

    mutating func set<T>(min: T?) {
        storage["min"] = min
    }

    func getMin<T>() -> T? {
        storage["min"] as? T
    }

    mutating func set<T>(max: T?) {
        storage["max"] = max
    }

    func getMax<T>() -> T? {
        storage["max"] as? T
    }

    func getRange<T>() -> ClosedRange<T>? {

        guard let min: T = getMin(), let max: T = getMax() else {
            return nil
        }

        return min...max
    }
}
