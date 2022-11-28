//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

#if os(iOS)
public typealias View = UIView
#else
public typealias View = NSView
#endif

public class Canvas: MTKView {
    var inputManager: InputManager?
    public var updateFlagManager = UpdateFlagManager()
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(with view: View) {
        super.init(frame: view.frame, device: nil)
        _setParentView(view)
        translatesAutoresizingMaskIntoConstraints = false
        depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        colorPixelFormat = MTLPixelFormat.bgra8Unorm
    }
    
    private func _setParentView(_ view: View) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public func dispatchResize() {
        updateFlagManager.dispatch(type: nil, param: self)
    }

    // MARK: - RawEvent
#if os(iOS)
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputManager?._pointerManager._onPointerEvent(touch)
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputManager?._pointerManager._onPointerEvent(touch)
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputManager?._pointerManager._onPointerEvent(touch)
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputManager?._pointerManager._onPointerEvent(touch)
        }
    }

    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    }

    public override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    }

    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    }

    public override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    }
#else
    public override var acceptsFirstResponder: Bool {
        true
    }
    
    public override func keyDown(with event: NSEvent) {
        inputManager?._keyboardManager._onKeyEvent(event)
    }

    public override func keyUp(with event: NSEvent) {
        inputManager?._keyboardManager._onKeyEvent(event)
    }
    
    public override func mouseDown(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func mouseUp(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func mouseDragged(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func mouseMoved(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func rightMouseDown(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func rightMouseUp(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func rightMouseDragged(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func otherMouseDown(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func otherMouseUp(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func otherMouseDragged(with event: NSEvent) {
        inputManager?._pointerManager._onPointerEvent(event)
    }

    public override func scrollWheel(with event: NSEvent) {
        inputManager?._wheelManager._onWheelEvent(event)
    }
    
#endif
}
