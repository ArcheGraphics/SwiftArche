//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

extension CGFloat: StringRepresentable {
    init?(stringRepresentation: String) {
        if let value = NumberFormatter().number(from: stringRepresentation).flatMap(CGFloat.init) {
            self = value
        } else {
            return nil
        }
    }
}

// MARK: - Foundation Geometry

#if os(macOS)

extension ViewMapping {

    static let nsPoint: ViewMapping = makeVector2Mapping(
            type: NSPoint.self,
            xName: "x",
            yName: "y",
            xPath: \.x,
            yPath: \.y
    )

    static let nsSize: ViewMapping = makeVector2Mapping(
            type: NSSize.self,
            xName: "w",
            yName: "h",
            xPath: \.width,
            yPath: \.height
    )
}

#endif

// MARK: - Core Graphics

extension ViewMapping {

    static let cgPoint: ViewMapping = makeVector2Mapping(
            type: CGPoint.self,
            xName: "x",
            yName: "y",
            xPath: \.x,
            yPath: \.y
    )

    static let cgSize: ViewMapping = makeVector2Mapping(
            type: CGSize.self,
            xName: "w",
            yName: "h",
            xPath: \.width,
            yPath: \.height
    )
}

// MARK: - Vector2 Mapping

extension ViewMapping {

    fileprivate static func makeVector2Mapping<T, FieldT>(type: T.Type,
                                                          xName: String,
                                                          yName: String,
                                                          xPath: WritableKeyPath<T, FieldT>,
                                                          yPath: WritableKeyPath<T, FieldT>) -> ViewMapping where FieldT: StringRepresentable {

        let mapping = ViewMapping(for: T.self) { ref, context in

            let state = context.state

            let xBinder = NumericEntryBinder(state: state, ref: ref, fieldPath: xPath)
            let yBinder = NumericEntryBinder(state: state, ref: ref, fieldPath: yPath)

            // tvOS shows editing screens modally, so we need the component name to also
            // display in the modal.
            func makeTitle(component: String) -> String {
                #if os(tvOS)
                return context.propertyName + "." + component
                #else
                return component
                #endif
            }

            let view = HStack {
                Text(context.propertyName)
                Spacer()
                Text("\(xName):")
                TextField(makeTitle(component: xName), text: xBinder.textBinding,
                          onCommit: { xBinder.commit() }).frame(maxWidth: 100)
                Text("\(yName):")
                TextField(makeTitle(component: yName), text: yBinder.textBinding,
                          onCommit: { yBinder.commit() }).frame(maxWidth: 100)
            }

            #if os(tvOS)
            if #available(tvOS 15.0, *) {
                return view.focusSection().asAnyView()
            } else {
                return view.asAnyView()
            }
            #else
            return view.asAnyView()
            #endif
        }
        return mapping
    }

}
