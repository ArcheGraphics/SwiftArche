//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

extension ViewMapping {
    static let string: ViewMapping = {
        let mapping = ViewMapping(for: String.self) { ref, context in

            var partial: String {
                get {
                    context.state.value["text"] as? String ?? ref.value
                }
                set {
                    context.state.value["text"] = newValue
                }
            }

            let binding = Binding(get: { partial },
                    set: { partial = $0 })

            let view = HStack {
                Text("\(context.propertyName):")
                TextField(context.propertyName, text: binding, onCommit: {
                    ref.value = partial
                    context.state.value["text"] = nil
                })
            }

            return AnyView(view)
        }
        return mapping
    }()
}
