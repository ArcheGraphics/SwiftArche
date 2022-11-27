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

/// Pointer.
public class Pointer {
    /// Unique id.
    public var id: Int
    /// The position of the pointer in screen space pixel coordinates.
    public var position: Vector2 = Vector2()
    /// The change of the pointer.
    public var deltaPosition: Vector2 = Vector2()

#if os(iOS)
    /// The phase of pointer.
    public var phase: UITouch.Phase = .cancelled
    /// The button that triggers the pointer event.
    public var button: UITouch.TouchType?
    /// The currently pressed buttons for this pointer.
    public var pressedButtons: UITouch.TouchType?
    var _events: [UITouch] = []
    var _upMap: [UITouch.TouchType: UInt64] = [:];
    var _downMap: [UITouch.TouchType: UInt64] = [:];
    var _upList: [UITouch.TouchType] = []
    var _downList: [UITouch.TouchType] = []
#else
    /// The phase of pointer.
    public var phase: NSEvent.Phase = .cancelled
    /// The button that triggers the pointer event.
    public var button: NSEvent.EventType?
    /// The currently pressed buttons for this pointer.
    public var pressedButtons: NSEvent.EventType?
    var _events: [NSEvent] = []
    var _upMap: [NSEvent.EventType: UInt64] = [:];
    var _downMap: [NSEvent.EventType: UInt64] = [:];
    var _upList: [NSEvent.EventType] = []
    var _downList: [NSEvent.EventType] = []
#endif

    var _uniqueID: Int = 0
    private var _currentPressedEntity: Entity?
    private var _currentEnteredEntity: Entity?

    init(_ id: Int) {
        self.id = id
    }

    func _firePointerExitAndEnter(_ rayCastEntity: Entity?) {
        if (_currentEnteredEntity !== rayCastEntity) {
            if (_currentEnteredEntity != nil) {
                let scripts = _currentEnteredEntity!._scripts
                for i in 0..<scripts.length {
                    let script = scripts.get(i)!
                    if !script._waitHandlingInValid {
                        script.onPointerExit(self)
                    }
                }
            }
            if (rayCastEntity != nil) {
                let scripts = rayCastEntity!._scripts
                for i in 0..<scripts.length {
                    let script = scripts.get(i)!
                    if !script._waitHandlingInValid {
                        script.onPointerEnter(self)
                    }
                }
            }
            _currentEnteredEntity = rayCastEntity
        }
    }

    func _firePointerDown(_ rayCastEntity: Entity?) {
        if (rayCastEntity != nil) {
            let scripts = rayCastEntity!._scripts
            for i in 0..<scripts.length {
                let script = scripts.get(i)!
                if !script._waitHandlingInValid {
                    script.onPointerDown(self)
                }
            }
        }
        _currentPressedEntity = rayCastEntity
    }

    func _firePointerDrag() {
        if (_currentPressedEntity != nil) {
            let scripts = _currentPressedEntity!._scripts
            for i in 0..<scripts.length {
                let script = scripts.get(i)!
                if !script._waitHandlingInValid {
                    script.onPointerDrag(self)
                }
            }
        }
    }

    func _firePointerUpAndClick(_ rayCastEntity: Entity?) {
        if (_currentPressedEntity != nil) {
            let sameTarget = _currentPressedEntity === rayCastEntity
            let scripts = _currentPressedEntity!._scripts
            for i in 0..<scripts.length {
                let script = scripts.get(i)!
                if !script._waitHandlingInValid {
                    if sameTarget {
                        script.onPointerClick(self)
                    }
                    script.onPointerUp(self)
                }
            }
            _currentPressedEntity = nil
        }
    }
}
