//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

class Canvas: MTKView {
    var inputManager: InputManager?

    typealias EventHandler = (AppleEvent) -> Void
    var mouseDownEvents: [EventHandler] = []
    var mouseUpEvents: [EventHandler] = []
    var rightMouseDownEvents: [EventHandler] = []
    var rightMouseUpEvents: [EventHandler] = []

    typealias KeyboardHandler = (KeyboardControl) -> Void
    var keyboardDownEvents: [KeyboardHandler] = []

    init() {
        super.init(frame: .zero, device: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
