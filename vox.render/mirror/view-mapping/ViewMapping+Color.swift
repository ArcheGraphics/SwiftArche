//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

#if os(iOS) || os(macOS)

extension ViewMapping {

    static let color: ViewMapping = {
        let mapping = ViewMapping(for: Color.self) { ref, context in

            let binding = Binding(get: { ref.value },
                    set: { ref.value = $0 })

            let picker = ColorPicker(context.propertyName, selection: binding)
            return AnyView(picker)
        }
        return mapping
    }()
}

#endif
