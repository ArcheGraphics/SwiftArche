//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import SwiftUI

protocol CaseIterableRefProvider {
    var caseIterableRef: CaseIterableRef { get }
}

class CaseIterableRef {
    struct Case {
        let value: Any
        let name: String
    }

    var allCases: [Case]
    private var get: () -> Any
    private var set: (Any) -> Void

    var value: Any {
        get {
            get()
        }
        set {
            set(newValue)
        }
    }

    private var getByIndex: () -> Int
    private var setByIndex: (Int) -> Void
    var valueIndex: Int {
        get {
            getByIndex()
        }
        set {
            setByIndex(newValue)
        }
    }

    var selectedCase: Case {
        return allCases[valueIndex]
    }

    init<T: CaseIterable & Equatable>(_ object: PropertyRef<T>) {

        var cases = [Case]()

        for c in type(of: object.value).allCases {
            let caseName = "\(c)"
            cases.append(
                    Case(value: c, name: PropertyNameFormatter.displayName(forPropertyName: caseName))
            )
        }

        allCases = cases

        get = {
            return object.value
        }

        set = {
            object.value = $0 as! T
        }

        getByIndex = {
            for (index, c) in type(of: object.value).allCases.enumerated() {
                if c == object.value {
                    return index
                }
            }
            return 0
        }

        setByIndex = {
            let allCases = type(of: object.value).allCases
            let index = allCases.index(allCases.startIndex, offsetBy: $0)
            object.value = type(of: object.value).allCases[index]
        }
    }
}

extension ViewMapping {
    static func makeCaseIterableView(ref: CaseIterableRef, context: ViewMappingContext) -> AnyView {
        let cases = ref.allCases

        let selectionBinding = Binding(get: { ref.valueIndex },
                set: { ref.valueIndex = $0 })

        #if os(macOS)

        let picker = Picker(selection: selectionBinding, label: Text(context.propertyName)) {
            ForEach(0..<cases.count, id: \.self) { index in
                let aCase = cases[index]
                Text("\(aCase.name)")
            }
        }
        .pickerStyle(MenuPickerStyle())
        return AnyView(picker)

        #elseif os(iOS)

        let picker = Picker(selection: selectionBinding, label: Text(ref.selectedCase.name)) {
            ForEach(0..<cases.count, id: \.self) { index in
                let aCase = cases[index]
                Text("\(aCase.name)")
            }
        }
        .pickerStyle(MenuPickerStyle())

        let pickerAndTitle = HStack {
            Text(context.propertyName)
            picker
        }
            .animation(.none, value: 0)

        return AnyView(pickerAndTitle)

        #else // tvOS

        let view = HStack {
            Text(context.propertyName)
            NavigationLink("\(cases[ref.valueIndex].name)") {
                self.makeSeparateScreenPicker(ref: ref, context: context)
            }
            .fixedSize(horizontal: true, vertical: false)
        }

        return view.asAnyView()
        #endif
    }

    #if os(tvOS)
    private static func makeSeparateScreenPicker(ref: CaseIterableRef, context: ViewMappingContext) -> some View {

        let cases = ref.allCases

        return List(Array(cases.enumerated()), id: \.element.name) { index, aCase in
            HStack {
                Button(aCase.name) {
                    ref.valueIndex = index
                }
                if index == ref.valueIndex {
                    Image(systemName: "checkmark").foregroundColor(.primary)
                }
            }
        }
        .navigationTitle(context.propertyName)
        .navigationBarHidden(false)
    }
    #endif
}


