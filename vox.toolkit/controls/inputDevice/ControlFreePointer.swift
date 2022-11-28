//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render

class ControlFreePointer : IControlInput {
    private static var _deltaType: DeltaType = DeltaType.Moving
    private static var _handlerType: ControlHandlerType = ControlHandlerType.None
    private static var _frameIndex: Int = 0
    private static var _lastUsefulFrameIndex: Int = -1
    static func onUpdateHandler(_ input: InputManager, callback: (ControlHandlerType)->Void) {
        _frameIndex += 1
        if (input.pointers.count == 1) {
            if (input.isPointerTrigger(.leftMouseDown)) {
                _updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
            } else {
                let pointer = input.pointers[0]
                if ((pointer.deltaX != 0 || pointer.deltaY != 0) && input.isPointerTrigger(.leftMouseUp)) {
                    _updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                } else {
                    _updateType(ControlHandlerType.None, DeltaType.None)
                }
            }
        } else {
            _updateType(ControlHandlerType.None, DeltaType.None)
        }
        callback(_handlerType)
    }
    
    static func onUpdateDelta(_ control: FreeControl, _ outDelta: inout Vector3) {
        switch (_deltaType) {
        case DeltaType.Moving:
            if (_lastUsefulFrameIndex == _frameIndex - 1) {
                let pointer = control.input.pointers[0]
                outDelta = Vector3(Float(pointer.deltaX), Float(pointer.deltaY), outDelta.z)
            } else {
                outDelta = Vector3(0, 0, outDelta.z)
            }
            break
        default:
            break
        }
        _lastUsefulFrameIndex = _frameIndex
    }
    
    private static func _updateType(_ handlerType: ControlHandlerType, _ deltaType: DeltaType) {
        if (_handlerType != handlerType || _deltaType != deltaType) {
            _handlerType = handlerType
            _deltaType = deltaType
            _lastUsefulFrameIndex = -1
        }
    }
}
