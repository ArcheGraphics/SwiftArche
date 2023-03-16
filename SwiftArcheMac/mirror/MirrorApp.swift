//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import SwiftUI
import Cocoa
import vox_render

enum Level: CaseIterable {
    case low
    case medium
    case high
}

enum Size: Int {
    case small
    case medium
    case large
}

class Settings {

    @MirrorUI var blurEnabled = false
    @MirrorUI var lives = 4
    @MirrorUI var startingHealth = CGFloat(4.6)
    @MirrorUI(range: 0...20) var damage = 5.3
    @MirrorUI var level = Level.low
    #if os(iOS) || os(macOS)
    @MirrorUI var bgColor: SwiftUI.Color = SwiftUI.Color.red
    #endif
    @MirrorUI var startPoint = CGPoint(x: 3, y: 5)
    @MirrorUI var endPoint = CGPoint(x: 3, y: 5)
    @MirrorUI var box = CGRect(x: 0, y: 1, width: 2, height: 3)
    @MirrorUI var size = Size.medium
    @MirrorUI var greeting = "Hello"
}

func makeCustomSizeViewMapping() -> ViewMapping {
    return ViewMapping(for: Size.self) { (ref, context) -> AnyView in

        let binding = Binding(get: { ref.value.rawValue },
                              set: { ref.value = Size(rawValue: $0)! })

        let view = VStack(alignment: .leading, spacing: 0) {
            #if os(iOS)
            Text(context.propertyName)
            #endif
            Picker(context.propertyName, selection: binding) {
                Text("Small").tag(0)
                Text("Medium").tag(1)
                Text("Large").tag(2)
            }
        }

        return AnyView(view)
    }
}

class MirrorApp: NSViewController {
    private let settings = Settings()
    private var mirrorHostingView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ViewMapper.shared.add(mapping: makeCustomSizeViewMapping())
        let mirrorView = MirrorView(object: settings)
        mirrorHostingView = NSHostingView(rootView: mirrorView)
        view.addSubview(mirrorHostingView)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        mirrorHostingView.frame = view.bounds
    }
}

