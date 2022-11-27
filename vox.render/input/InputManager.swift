//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

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

#if os(iOS)
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
    public func isPointerUp() -> Bool {
        if (_initialized) {
            return _pointerManager._upList.count > 0
        } else {
            return false
        }
    }
#else
    /// Whether the pointer is being held down, if there is no parameter, return whether any pointer is being held down.
    /// - Returns: Whether the pointer is being held down
    public func isPointerHeldDown(_ pointerButton: NSEvent.EventType) -> Bool {
        if (_initialized) {
            return (_pointerManager._buttons & pointerButton.rawValue) != 0
        } else {
            return false
        }
    }

    /// Whether the pointer starts to be pressed down during the current frame, if there is no parameter,
    /// return whether any pointer starts to be pressed down during the current frame.
    /// - Returns: Whether the pointer starts to be pressed down during the current frame
    public func isPointerDown(_ pointerButton: NSEvent.EventType) -> Bool {
        if (_initialized) {
            return _pointerManager._downMap[pointerButton] == _curFrameCount
        } else {
            return false
        }
    }

    /// Whether the pointer is released during the current frame, if there is no parameter,
    /// return whether any pointer released during the current frame.
    /// - Returns: Whether the pointer is released during the current frame
    public func isPointerUp(_ pointerButton: NSEvent.EventType) -> Bool {
        if (_initialized) {
            return _pointerManager._upMap[pointerButton] == _curFrameCount
        } else {
            return false
        }
    }
#endif

    func _update() {
        if (_initialized) {
            _curFrameCount += 1
            _pointerManager._update(_curFrameCount)
        }
    }
}
