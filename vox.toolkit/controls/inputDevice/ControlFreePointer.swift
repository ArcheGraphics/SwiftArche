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
    static func onUpdateHandler(_ input: InputManager) -> ControlHandlerType {
        _frameIndex += 1
        if (input.pointers.count == 1) {
            if (input.isPointerHeldDown(.leftMouseDown)) {
                _updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
            } else {
                let deltaPosition = input.pointers[0].deltaPosition
                if ((deltaPosition.x != 0 || deltaPosition.y != 0) && input.isPointerUp(.leftMouseUp)) {
                    _updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                } else {
                    _updateType(ControlHandlerType.None, DeltaType.None)
                }
            }
        } else {
            _updateType(ControlHandlerType.None, DeltaType.None)
        }
        return _handlerType
    }
    
    static func onUpdateDelta(_ control: FreeControl, _ outDelta: inout Vector3) {
        switch (_deltaType) {
        case DeltaType.Moving:
            if (_lastUsefulFrameIndex == _frameIndex - 1) {
                let deltaPosition = control.input.pointers[0].deltaPosition
                outDelta = Vector3(deltaPosition.x, deltaPosition.y, outDelta.z)
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
