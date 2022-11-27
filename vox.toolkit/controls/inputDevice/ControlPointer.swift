//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render

enum DeltaType {
    case Moving
    case Distance
    case None
}

class ControlPointer : IControlInput {
    private static var _deltaType: DeltaType = DeltaType.None
    private static var _handlerType: ControlHandlerType = ControlHandlerType.None
    private static var _frameIndex: Int = 0
    private static var _lastUsefulFrameIndex: Int = -1
    private static var _distanceOfPointers: Float = 0
    
    static func onUpdateHandler(_ input: InputManager) -> ControlHandlerType {
        _frameIndex += 1
        let pointers = input.pointers
        switch (pointers.count) {
        case 1:
            if (input.isPointerHeldDown(.rightMouseDown)) {
                ControlPointer._updateType(ControlHandlerType.PAN, DeltaType.Moving)
            } else if (input.isPointerHeldDown(.otherMouseDown)) {
                ControlPointer._updateType(ControlHandlerType.ZOOM, DeltaType.Moving)
            } else if (input.isPointerHeldDown(.leftMouseDown)) {
                ControlPointer._updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
            } else {
                // When `onPointerMove` happens on the same frame as `onPointerUp`
                // Need to record the movement of this frame
                let deltaPosition = input.pointers[0].deltaPosition
                if (deltaPosition.x != 0 && deltaPosition.y != 0) {
                    if (input.isPointerUp(.rightMouseUp)) {
                        ControlPointer._updateType(ControlHandlerType.PAN, DeltaType.Moving)
                    } else if (input.isPointerUp(.otherMouseUp)) {
                        ControlPointer._updateType(ControlHandlerType.ZOOM, DeltaType.Moving)
                    } else if (input.isPointerUp(.leftMouseUp)) {
                        ControlPointer._updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                    } else {
                        ControlPointer._updateType(ControlHandlerType.None, DeltaType.None)
                    }
                } else {
                    ControlPointer._updateType(ControlHandlerType.None, DeltaType.None)
                }
            }
            break
        case 2:
            ControlPointer._updateType(ControlHandlerType.ZOOM, DeltaType.Distance)
            break
        case 3:
            ControlPointer._updateType(ControlHandlerType.PAN, DeltaType.Moving)
            break
        default:
            ControlPointer._updateType(ControlHandlerType.None, DeltaType.None)
            break
        }
        return ControlPointer._handlerType
    }
    
    static func onUpdateDelta(_ control: OrbitControl, outDelta: inout Vector3) {
        var outDeltaVec = SIMD3<Float>(repeating: 0.0)
        switch (ControlPointer._deltaType) {
        case DeltaType.Moving:
            outDeltaVec.x = 0
            outDeltaVec.y = 0
            if (ControlPointer._lastUsefulFrameIndex == _frameIndex - 1) {
                let pointers = control.input.pointers
                let length = pointers.count
                for i in 0..<length {
                    let deltaPosition = pointers[i].deltaPosition
                    outDeltaVec.x += deltaPosition.x
                    outDeltaVec.y += deltaPosition.y
                }
                outDeltaVec.x /= Float(length)
                outDeltaVec.y /= Float(length)
            }
            break
        case DeltaType.Distance:
            let pointers = control.input.pointers
            let pointer1 = pointers[0]
            let pointer2 = pointers[1]
            let curDistance = Vector2.distance(left: pointer1.position, right: pointer2.position)
            if (ControlPointer._lastUsefulFrameIndex == _frameIndex - 1) {
                outDeltaVec = SIMD3<Float>(0, ControlPointer._distanceOfPointers - curDistance, 0)
            }
            ControlPointer._distanceOfPointers = curDistance
            break
        default:
            break
        }
        outDelta = Vector3(outDeltaVec)
        ControlPointer._lastUsefulFrameIndex = _frameIndex
    }
    
    private static func _updateType(_ handlerType: ControlHandlerType, _ deltaType: DeltaType) {
        if (ControlPointer._handlerType != handlerType || ControlPointer._deltaType != deltaType) {
            ControlPointer._handlerType = handlerType
            ControlPointer._deltaType = deltaType
            ControlPointer._lastUsefulFrameIndex = -1
        }
    }
}
