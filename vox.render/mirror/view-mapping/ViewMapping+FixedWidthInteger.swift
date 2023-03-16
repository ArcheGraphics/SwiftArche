//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

extension ViewMapping {
    static let int: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: Int.self, stringInit: Int.init)
    }()

    static let int16: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: Int16.self, stringInit: Int16.init)
    }()

    static let int32: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: Int32.self, stringInit: Int32.init)
    }()

    static let int64: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: Int64.self, stringInit: Int64.init)
    }()

    static let int8: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: Int8.self, stringInit: Int8.init)
    }()

    static let uInt: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: UInt.self, stringInit: UInt.init)
    }()

    static let uInt16: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: UInt16.self, stringInit: UInt16.init)
    }()

    static let uInt32: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: UInt32.self, stringInit: UInt32.init)
    }()

    static let uInt64: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: UInt64.self, stringInit: UInt64.init)
    }()

    static let uInt8: ViewMapping = {
        return makeFixedWidthIntegerMapping(forType: UInt8.self, stringInit: UInt8.init)
    }()

    static func makeFixedWidthIntegerMapping<T: FixedWidthInteger>(forType: T.Type,
                                                                   stringInit: @escaping (String) -> T?) -> ViewMapping {

        return ViewMapping(for: T.self) { ref, context in

            let state = context.state

            var editText: String? {
                get {
                    state.value[string: "text"] ?? String("\(ref.value)")
                }
                set {
                    state.value["text"] = newValue
                }
            }

            // Make bindings
            let textBinding = Binding(get: { editText ?? "" },
                    set: { editText = $0 })

            func commitEditText() {
                if let text = editText, let value = stringInit(text) {
                    ref.value = value
                }
                editText = nil
            }

            // On tvOS, text input is shown modally, so we need to display the title on the
            // modal screen. On iOS it's shown inline in the text field next to the title
            // label, so we don't need to repeat it.
            let textFieldTitle: String
            #if os(tvOS)
            textFieldTitle = context.propertyName
            #else
            textFieldTitle = "Value"
            #endif

            // Create view
            return HStack {
                Text(context.propertyName)
                        .frame(maxHeight: .infinity)
                TextField(textFieldTitle, text: textBinding, onCommit: { commitEditText() })
                        .frame(maxHeight: .infinity)
                Button {
                    editText = nil
                    if ref.value.subtractingReportingOverflow(1).overflow == false {
                        ref.value -= 1
                    }
                } label: {
                    Image(systemName: "minus").frame(maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)
                Button {
                    editText = nil
                    if ref.value.addingReportingOverflow(1).overflow == false {
                        ref.value += 1
                    }
                } label: {
                    Image(systemName: "plus").frame(maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)
            }
            .asAnyView()
        }
    }

}
