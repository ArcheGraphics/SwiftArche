//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

enum DeltaType {
    case Moving
    case Distance
    case None
}

class ControlPointer: IControlInput {
    private static var _deltaType: DeltaType = .None
    private static var _handlerType: ControlHandlerType = .None
    private static var _frameIndex: Int = 0
    private static var _lastUsefulFrameIndex: Int = -1
    private static var _distanceOfPointers: Float = 0

    static func onUpdateHandler(_ input: InputManager, callback: (ControlHandlerType) -> Void) {
        _frameIndex += 1
        let pointers = input.pointers
        for pointer in pointers {
            if pointer.type == .rightMouseDown {
                ControlPointer._updateType(ControlHandlerType.PAN, DeltaType.Moving)
                callback(ControlPointer._handlerType)
            } else if pointer.type == .otherMouseDown {
                ControlPointer._updateType(ControlHandlerType.ZOOM, DeltaType.Moving)
                callback(ControlPointer._handlerType)
            } else if pointer.type == .leftMouseDown {
                ControlPointer._updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                callback(ControlPointer._handlerType)
            } else if pointer.type == .rightMouseDragged {
                ControlPointer._updateType(ControlHandlerType.PAN, DeltaType.Moving)
                callback(ControlPointer._handlerType)
            } else if pointer.type == .otherMouseDragged {
                ControlPointer._updateType(ControlHandlerType.ZOOM, DeltaType.Moving)
                callback(ControlPointer._handlerType)
            } else if pointer.type == .leftMouseDragged {
                ControlPointer._updateType(ControlHandlerType.ROTATE, DeltaType.Moving)
                callback(ControlPointer._handlerType)
            } else {
                ControlPointer._updateType(ControlHandlerType.None, DeltaType.None)
                callback(ControlPointer._handlerType)
            }
        }
    }

    static func onUpdateDelta(_ control: OrbitControl, _ outDelta: inout Vector3) {
        var outDeltaVec = SIMD3<Float>(repeating: 0.0)
        switch ControlPointer._deltaType {
        case DeltaType.Moving:
            outDeltaVec.x = 0
            outDeltaVec.y = 0
            if ControlPointer._lastUsefulFrameIndex == _frameIndex - 1 {
                let pointers = control.input.pointers
                let length = pointers.count
                for i in 0 ..< length {
                    let pointer = pointers[i]
                    outDeltaVec.x += Float(pointer.deltaX)
                    outDeltaVec.y += Float(pointer.deltaY)
                }
                outDeltaVec.x /= Float(length)
                outDeltaVec.y /= Float(length)
            }
        case DeltaType.Distance:
            let canvas = control.canvas
            let pointers = control.input.pointers
            if let canvas {
                let curDistance = Vector2.distance(left: pointers[0].screenPoint(canvas),
                                                   right: pointers[1].screenPoint(canvas))
                if ControlPointer._lastUsefulFrameIndex == _frameIndex - 1 {
                    outDeltaVec = SIMD3<Float>(0, ControlPointer._distanceOfPointers - curDistance, 0)
                }
                ControlPointer._distanceOfPointers = curDistance
            }
        default:
            break
        }
        outDelta = Vector3(outDeltaVec)
        ControlPointer._lastUsefulFrameIndex = _frameIndex
    }

    private static func _updateType(_ handlerType: ControlHandlerType, _ deltaType: DeltaType) {
        if ControlPointer._handlerType != handlerType || ControlPointer._deltaType != deltaType {
            ControlPointer._handlerType = handlerType
            ControlPointer._deltaType = deltaType
            ControlPointer._lastUsefulFrameIndex = -1
        }
    }
}
