//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

public class Canvas: MTKView {
    var inputManager: InputManager?
    public var updateFlagManager = UpdateFlagManager()

    public var isMultipleTouchEnabled:Bool {
        get {
#if os(iOS)
            super.isMultipleTouchEnabled
#else
            false
#endif
        }
        set {
#if os(iOS)
            super.isMultipleTouchEnabled = newValue            
#endif
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(frame frameRect: CGRect) {
        super.init(frame: frameRect, device: nil)
        translatesAutoresizingMaskIntoConstraints = false
        depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        colorPixelFormat = MTLPixelFormat.bgra8Unorm
    }

#if os(iOS)
    public func setParentView(_ view: UIView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
#else
    public func setParentView(_ view: NSView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
#endif

    public func dispatchResize() {
        updateFlagManager.dispatch(type: nil, param: self)
    }

    // MARK: - RawEvent
#if os(iOS)
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    public override func keyDown(with event: NSEvent) {
    }

    public override func keyUp(with event: NSEvent) {
    }
    
    public override func mouseDown(with event: NSEvent) {
    }

    public override func mouseUp(with event: NSEvent) {
    }

    public override func mouseDragged(with event: NSEvent) {
    }

    public override func mouseMoved(with event: NSEvent) {
    }

    public override func rightMouseDown(with event: NSEvent) {
    }

    public override func rightMouseUp(with event: NSEvent) {
    }

    public override func rightMouseDragged(with event: NSEvent) {
    }

    public override func otherMouseDown(with event: NSEvent) {
    }

    public override func otherMouseUp(with event: NSEvent) {
    }

    public override func otherMouseDragged(with event: NSEvent) {
    }

    public override func scrollWheel(with event: NSEvent) {
    }
    
#endif
}
