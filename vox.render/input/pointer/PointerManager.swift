//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
#if os(iOS)
import UIKit
#else
import Cocoa
#endif

class PointerManager {
#if os(iOS)
    var _pointers: [UITouch] = []
    private var _nativeEvents: [UITouch] = []

    
    func _onPointerEvent(_ evt: UITouch) {
        _nativeEvents.append(evt)
    }
    
    func isPointerTrigger(_ pointerButton: UITouch.Phase) -> Bool {
        for evt in _pointers {
            if evt.phase == pointerButton {
                return true
            }
        }
        return false
    }
#else
    var _pointers: [NSEvent] = []
    private var _nativeEvents: [NSEvent] = []

    func _onPointerEvent(_ evt: NSEvent) {
        _nativeEvents.append(evt)
    }
    
    func isPointerTrigger(_ pointerButton: NSEvent.EventType) -> Bool {
        for evt in _pointers {
            if evt.type == pointerButton {
                return true
            }
        }
        return false
    }
#endif
    
    func _update() {
        _pointers = _nativeEvents
        _nativeEvents = []
    }

}
