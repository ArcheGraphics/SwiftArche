//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

public class Canvas: MTKView {
    var inputManager: InputManager?

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(frame frameRect: CGRect) {
        super.init(frame: frameRect, device: nil)
        translatesAutoresizingMaskIntoConstraints = false
        depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        colorPixelFormat = MTLPixelFormat.bgra8Unorm
    }

    public func setParentView(_ view: UIView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - RawEvent
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
}
