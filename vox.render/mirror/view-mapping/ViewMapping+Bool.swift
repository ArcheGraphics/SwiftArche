//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

extension ViewMapping {

    static let bool: ViewMapping = {
        let mapping = ViewMapping(for: Bool.self) { ref, context in

            let binding = Binding(get: { ref.value },
                    set: { ref.value = $0 })

            let toggle = Toggle(context.propertyName, isOn: binding)
            return AnyView(toggle)
        }
        return mapping
    }()
}
