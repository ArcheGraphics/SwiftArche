//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import SwiftUI

struct ObjectProperty: Identifiable {
    var id: String {
        name
    }
    let name: String
    let displayName: String
    var viewStateStorage: Ref<[String: Any]> = Ref(value: [:])
    var objectRef: AnyObject
    var isEnum: Bool
}

class ReloadTrigger: ObservableObject {
    func reload() {
        self.objectWillChange.send()
    }
}

public struct MirrorView: View {
    private let object: AnyObject
    private let objectProperties: [ObjectProperty]
    private let viewMapper: ViewMapper
    @ObservedObject private var reloadTrigger: ReloadTrigger

    public init(object: AnyObject, viewMapper: ViewMapper = .shared) {
        self.object = object
        self.viewMapper = viewMapper
        let objectProperties = Self.getProperties(from: object)

        let reloadTrigger = ReloadTrigger()
        for property in objectProperties {
            property.viewStateStorage.didSet = { _ in
                reloadTrigger.reload()
            }
            if let didSetCaller = property.objectRef as? InternalDidSetCaller {
                didSetCaller.internalDidSet = {
                    reloadTrigger.reload()
                }
            }
        }

        self.objectProperties = objectProperties
        self.reloadTrigger = reloadTrigger
    }

    static func getProperties(from object: AnyObject) -> [ObjectProperty] {

        let children = Mirror(reflecting: object).children
        var properties = [ObjectProperty]()

        for child in children where child.value is MirrorControl {
            let mirrorControl = child.value as! MirrorControl
            guard let label = child.label else {
                continue
            }
            let property = ObjectProperty(
                    name: label,
                    displayName: mirrorControl.name ?? PropertyNameFormatter.displayName(forPropertyName: label),
                    objectRef: mirrorControl.mirrorObject,
                    isEnum: (mirrorControl is CaseIterableRefProvider))

            properties.append(property)
        }

        return properties
    }

    public var body: some View {
        // tvOS pushes additional views for editing, so we need to wrap the body in a
        // NavigationView
        #if os(tvOS)
        return NavigationView {
            makeBody()
        }
        #else
        return makeBody()
        #endif
    }

    private func makeBody() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                ForEach(objectProperties) { property -> AnyView in

                    self.makeControlView(
                            propertyName: property.name,
                            displayName: property.displayName,
                            state: property.viewStateStorage
                    )

                }
                Spacer()
            }
                    .padding()
        }
    }

    private func makeControlView(propertyName: String, displayName: String, state: Ref<[String: Any]>) -> AnyView {
        let value = Mirror(reflecting: object).children
                .first {
                    $0.label == propertyName
                }
                .flatMap {
                    $0.value
                }!

        guard let control = value as? MirrorControl else {
            assertionFailure("All properties should be mirror controls")
            return makeNoMappingView(name: propertyName)
        }

        let context = ViewMappingContext(
                propertyName: displayName,
                properties: control.properties,
                state: state
        )

        if let caseIterableRefProvider = control as? CaseIterableRefProvider {
            return ViewMapping.makeCaseIterableView(ref: caseIterableRefProvider.caseIterableRef,
                    context: context)
        } else if let property = control.mirrorObject as? PropertyRefCastable {
            return viewMapper.createView(object: property, context: context) ?? makeNoMappingView(name: propertyName)
        } else {
            return makeNoMappingView(name: propertyName)
        }
    }

    private func makeNoMappingView(name: String) -> AnyView {
        let text = Text("No mapping (\(name))").foregroundColor(.gray).italic()
        return AnyView(text)
    }
}
