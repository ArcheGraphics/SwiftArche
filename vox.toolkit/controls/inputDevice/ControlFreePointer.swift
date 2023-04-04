//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class ControlFreePointer: IControlInput {
    private static var _deltaType: DeltaType = .Moving
    private static var _handlerType: ControlHandlerType = .None
    private static var _frameIndex: Int = 0
    private static var _lastUsefulFrameIndex: Int = -1
    static func onUpdateHandler(_ input: InputManager, callback: (ControlHandlerType) -> Void) {
        _frameIndex += 1

        let pointers = input.pointers
        for pointer in pointers {
            if pointer.type == .leftMouseDown {
                ControlFreePointer._updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                callback(ControlFreePointer._handlerType)
            } else if pointer.type == .leftMouseDragged {
                ControlFreePointer._updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                callback(ControlFreePointer._handlerType)
            } else {
                ControlFreePointer._updateType(ControlHandlerType.None, DeltaType.None)
                callback(ControlFreePointer._handlerType)
            }
        }
    }

    static func onUpdateDelta(_ control: FreeControl, _ outDelta: inout Vector3) {
        switch _deltaType {
        case DeltaType.Moving:
            if _lastUsefulFrameIndex == _frameIndex - 1 {
                let pointer = control.input.pointers[0]
                outDelta = Vector3(Float(pointer.deltaX), Float(pointer.deltaY), outDelta.z)
            } else {
                outDelta = Vector3(0, 0, outDelta.z)
            }
        default:
            break
        }
        _lastUsefulFrameIndex = _frameIndex
    }

    private static func _updateType(_ handlerType: ControlHandlerType, _ deltaType: DeltaType) {
        if _handlerType != handlerType || _deltaType != deltaType {
            _handlerType = handlerType
            _deltaType = deltaType
            _lastUsefulFrameIndex = -1
        }
    }
}
