//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

/// Creates a text binding to a numeric field.
class NumericEntryBinder {
    let textBinding: Binding<String>

    private let _commit: () -> Void
    private let _clear: () -> Void

    convenience init<T>(state: Ref<[String: Any]>, ref: PropertyRef<T>) where T: StringRepresentable {

        self.init(state: state,
                get: { ref.value },
                set: { ref.value = $0 },
                stateKey: "text")
    }

    convenience init<T, F>(state: Ref<[String: Any]>, ref: PropertyRef<T>, fieldPath: WritableKeyPath<T, F>) where F: StringRepresentable {

        self.init(state: state,
                get: { ref.value[keyPath: fieldPath] },
                set: { ref.value[keyPath: fieldPath] = $0 },
                stateKey: "text\(fieldPath.hashValue)")
    }

    init<F>(state: Ref<[String: Any]>,
            get: @escaping () -> F,
            set: @escaping (F) -> Void,
            stateKey: String) where F: StringRepresentable {

        let textKey = stateKey //"text\(fieldPath.hashValue)"
        var editText: String? {
            get {
                state.value[string: textKey] ?? String("\(get())")
            }
            set {
                state.value[textKey] = newValue
            }
        }

        _commit = {
            if let text = editText, let value = F(stringRepresentation: text) {
                set(value)
            }
            editText = nil
        }

        _clear = {
            editText = nil
        }

        textBinding = Binding(get: { editText ?? "" },
                set: { editText = $0 })
    }

    func commit() {
        _commit()
    }

    func clear() {
        _clear()
    }
}
