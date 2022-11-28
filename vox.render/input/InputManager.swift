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
import vox_math

/// InputManager manages device input such as mouse, touch, keyboard, etc.
public class InputManager {
    /// Sometimes the input module will not be initialized, such as off-screen rendering.
    private var _initialized: Bool = false
    private var _curFrameCount: UInt64 = 0
    var _pointerManager: PointerManager
#if os(macOS)
    var _wheelManager: WheelManager
    var _keyboardManager: KeyboardManager
#endif
    
#if os(iOS)
    /// Pointer list.
    public var pointers: [UITouch] {
        get {
            _initialized ? _pointerManager._pointers : []
        }
    }
#else
    /// Pointer list.
    public var pointers: [NSEvent] {
        get {
            _initialized ? _pointerManager._pointers : []
        }
    }
#endif
    
    init(engine: Engine) {
        _pointerManager = PointerManager()
#if os(macOS)
        _wheelManager = WheelManager()
        _keyboardManager = KeyboardManager()
#endif
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
    public func isPointerTrigger(_ pointerButton: NSEvent.EventType) -> Bool {
        if (_initialized) {
            return _pointerManager.isPointerTrigger(pointerButton)
        } else {
            return false
        }
    }
    
    /// Get the change of the scroll wheel on the x-axis.
    public var wheelDelta:Vector3 {
        get {
            _wheelManager._delta
        }
    }
    
    /// Whether the key is being held down, if there is no parameter, return whether any key is being held down.
    /// - Parameter key: The keys of the keyboard
    /// - Returns: Whether the key is being held down
    public func isKeyHeldDown(_ key: Keys? = nil)->Bool {
        if (_initialized) {
            if (key == nil) {
                return _keyboardManager._curFrameHeldDownList.count > 0
            } else {
                return _keyboardManager._curHeldDownKeyToIndexMap[key!] != nil
            }
        } else {
            return false
        }
    }
    
    /// Whether the key starts to be pressed down during the current frame, if there is no parameter, return whether any key starts to be pressed down during the current frame.
    /// - Parameter key: The keys of the keyboard
    /// - Returns: Whether the key starts to be pressed down during the current frame
    public func isKeyDown(_ key: Keys? = nil)->Bool {
        if (_initialized) {
            if (key == nil) {
                return _keyboardManager._curFrameDownList.count > 0
            } else {
                return _keyboardManager._downKeyToFrameCountMap[key!] == _curFrameCount
            }
        } else {
            return false
        }
    }
    
    /// Whether the key is released during the current frame, if there is no parameter, return whether any key released during the current frame.
    /// - Parameter key: The keys of the keyboard
    /// - Returns: Whether the key is released during the current frame
    public func isKeyUp(_ key: Keys? = nil)->Bool {
        if (_initialized) {
            if (key == nil) {
                return _keyboardManager._curFrameUpList.count > 0
            } else {
                return _keyboardManager._upKeyToFrameCountMap[key!] == _curFrameCount
            }
        } else {
            return false
        }
    }
#endif
    
    func _update() {
        if (_initialized) {
            _pointerManager._update()
#if os(macOS)
            _curFrameCount += 1
            _keyboardManager._update(_curFrameCount)
            _wheelManager._update()
#endif
        }
    }
}
