//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

protocol PropertyRefCastable {
    func maybeCast<Target>(to: Target.Type) -> PropertyRef<Target>?
}

extension PropertyRef: PropertyRefCastable {
}

struct GetterSetter<T> {
    var get: () -> T
    var set: (T) -> Void
}

private enum Value<T> {
    case stored(T)
    case proxy(GetterSetter<T>)

    var value: T {
        get {
            switch self {
            case .stored(let v):
                return v
            case .proxy(let proxy):
                return proxy.get()
            }
        }
        set {
            switch self {
            case .stored:
                self = .stored(newValue)
            case .proxy(let proxy):
                proxy.set(newValue)
            }
        }
    }

}

public class PropertyRef<T>: InternalDidSetCaller {
    var didSet: (T) -> Void = { _ in
    }
    var internalDidSet: () -> Void = {
    }
    private var valueModifiers = [String: (T) -> T]()

    private var _value: Value<T>

    public var value: T {
        get {
            _value.value
        }
        set {
            _value.value = modify(value: newValue)
            internalDidSet()
            didSet(_value.value)
        }
    }

    init(value: T) {
        self._value = .stored(value)
    }

    init(getterSetter: GetterSetter<T>) {
        self._value = .proxy(getterSetter)
    }

    func set(valueModifier: @escaping (T) -> T, forKey key: String) {
        valueModifiers[key] = valueModifier
    }

    private func modify(value: T) -> T {

        var modified = value
        for modifier in valueModifiers.values {
            modified = modifier(modified)
        }
        return modified
    }

    func maybeCast<Target>(to: Target.Type) -> PropertyRef<Target>? {

        // Check is already target
        if let asTarget = self as? PropertyRef<Target> {
            return asTarget
        }

        // Or can cast to target
        guard self.value is Target else {
            return nil
        }

        let getterSetter = GetterSetter<Target>(get: { self.value as! Target },
                set: { self.value = $0 as! T })

        return PropertyRef<Target>(getterSetter: getterSetter)

    }
}

protocol InternalDidSetCaller: AnyObject {
    var internalDidSet: () -> Void { get set }
}
