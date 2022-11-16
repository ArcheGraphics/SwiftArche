//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import UIKit

/// Pointer.
public class Pointer {
    /// Unique id.
    public var id: Int
    /// The phase of pointer.
    public var phase: UITouch.Phase = .cancelled
    /// The button that triggers the pointer event.
    public var button: PointerButton = .None
    /// The currently pressed buttons for this pointer.
    public var pressedButtons: PointerButton = .None
    /// The position of the pointer in screen space pixel coordinates.
    public var position: Vector2 = Vector2()
    /// The change of the pointer.
    public var deltaPosition: Vector2 = Vector2()
    var _events: [UITouch] = []
    var _uniqueID: Int = 0
    var _upMap: [Int] = []
    var _downMap: [Int] = []
    var _upList: [PointerButton] = []
    var _downList: [PointerButton] = []
    private var _currentPressedEntity: Entity?
    private var _currentEnteredEntity: Entity?

    init(_ id: Int) {
        self.id = id
    }

    func _firePointerExitAndEnter(rayCastEntity: Entity?) {
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

    func _firePointerDown(rayCastEntity: Entity?) {
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

    func _firePointerUpAndClick(rayCastEntity: Entity?) {
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