//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// InputManager manages device input such as mouse, touch, keyboard, etc.
public class InputManager {
    /// Sometimes the input module will not be initialized, such as off-screen rendering.
    private var _initialized: Bool = false
    private var _curFrameCount: UInt64 = 0
    private var _pointerManager: PointerManager

    /// Pointer list.
    public var pointers: [Pointer] {
        get {
            _initialized ? _pointerManager._pointers : []
        }
    }

    init(engine: Engine) {
        _pointerManager = PointerManager(engine)
        _initialized = true
    }

    /// Whether the pointer is being held down, if there is no parameter, return whether any pointer is being held down.
    /// - Returns: Whether the pointer is being held down
    public func isPointerHeldDown() -> Bool {
        if (_initialized) {
            return _pointerManager._buttons != 0
        } else {
            return false
        }
    }

    /// Whether the pointer starts to be pressed down during the current frame, if there is no parameter,
    /// return whether any pointer starts to be pressed down during the current frame.
    /// - Returns: Whether the pointer starts to be pressed down during the current frame
    public func isPointerDown() -> Bool {
        if (_initialized) {
            return _pointerManager._downList.count > 0
        } else {
            return false
        }
    }

    /// Whether the pointer is released during the current frame, if there is no parameter,
    /// return whether any pointer released during the current frame.
    /// - Returns: Whether the pointer is released during the current frame
    func isPointerUp() -> Bool {
        if (_initialized) {
            return _pointerManager._upList.count > 0
        } else {
            return false
        }
    }

    func _update() {
        if (_initialized) {
            _curFrameCount += 1
            _pointerManager._update()
        }
    }
}