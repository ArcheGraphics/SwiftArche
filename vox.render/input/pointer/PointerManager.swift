//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import UIKit

class PointerManager {
    var _pointers: [Pointer] = []
    var _multiPointerEnabled: Bool = true
    var _buttons: Int = PointerButton.None.rawValue
    var _upMap: [Int] = [0, 0]
    var _downMap: [Int] = [0, 0]
    var _upList: [PointerButton] = []
    var _downList: [PointerButton] = []

    private var _engine: Engine
    private var _canvas: Canvas
    private var _nativeEvents: [UITouch] = []
    private var _pointerPool: [Pointer?] = [Pointer?](repeating: nil, count: 11)
    private var _hadListener: Bool = false

    init(_ engine: Engine) {
        _engine = engine
        _canvas = engine.canvas
    }

    func _update(_ frameCount: Int) {
        /** Clean up the pointer released in the previous frame. */
        var lastIndex = _pointers.count - 1
        if (lastIndex >= 0) {
            var i = lastIndex
            while i >= 0 {
                if (_pointers[i].phase == .cancelled) {
                    if (i != lastIndex) {
                        _pointers[i] = _pointers[lastIndex]
                    }
                    lastIndex -= 1
                }
                i -= 1
            }
            _pointers = _pointers.dropLast(_pointers.count - lastIndex - 1)
        }

        /** Generate the pointer received for this frame. */
        lastIndex = _nativeEvents.count - 1
        if (lastIndex >= 0) {
            for i in 0...lastIndex {
                let evt = _nativeEvents[i]
                _getPointer(evt.hash)?._events.append(evt)
            }
            _nativeEvents = []
        }

        /** Pointer handles its own events. */
        _upList = []
        _downList = []
        _buttons = PointerButton.None.rawValue
        lastIndex = _pointers.count - 1
        if (lastIndex >= 0) {
            for i in 0..<lastIndex {
                let pointer = _pointers[i]
                pointer._upList = []
                pointer._downList = []
                _updatePointer(frameCount, pointer, Float(_canvas.bounds.width), Float(_canvas.bounds.height))
                _buttons |= pointer.pressedButtons.rawValue
            }
        }
    }

    private func _getIndexByPointerID(_ pointerId: Int) -> Int {
        for i in 0..<_pointers.count {
            if (_pointers[i]._uniqueID == pointerId) {
                return i
            }
        }
        return -1
    }

    private func _getPointer(_ pointerId: Int) -> Pointer? {
        let index = _getIndexByPointerID(pointerId)
        if (index >= 0) {
            return _pointers[index]
        } else {
            let lastCount = _pointers.count
            if (lastCount == 0 || _multiPointerEnabled) {
                // Get Pointer smallest index.
                var i = 0
                while i < lastCount {
                    if (_pointers[i].id > i) {
                        break
                    }
                    i += 1
                }
                var pointer = _pointerPool[i]
                if (pointer == nil) {
                    pointer = Pointer(i)
                    _pointerPool[i] = pointer
                }
                pointer!._uniqueID = pointerId
                _pointers[i] = pointer!
                return pointer
            } else {
                return nil
            }
        }
    }

    private func _updatePointer(_ frameCount: Int, _ pointer: Pointer,
                                _ canvasW: Float, _ canvasH: Float) {
        let events = pointer._events
        let position = pointer.position
        let length = events.count
        if (length > 0) {
            let latestEvent = events[length - 1]
            let location = latestEvent.location(in: _canvas)
            let previousLocation = latestEvent.previousLocation(in: _canvas)
            pointer.phase = latestEvent.phase
            _ = pointer.deltaPosition.set(x: Float(location.x - previousLocation.x), y: Float(location.y - previousLocation.y))
            _ = pointer.position.set(x: Float(location.x), y: Float(location.y))

            pointer._firePointerDrag()
            let rayCastEntity = _pointerRayCast(Float(location.x) / canvasW, Float(location.y) / canvasH)
            pointer._firePointerExitAndEnter(rayCastEntity)
            for i in 0..<length {
                let event = events[i]
                let button = 1
                pointer.button = .Primary
                pointer.pressedButtons = .Primary
                switch (event.phase) {
                case .began:
                    _downList.append(.Primary)
                    _downMap[button] = frameCount
                    pointer._downList.append(.Primary)
                    pointer._downMap[button] = frameCount
                    pointer.phase = .began
                    pointer._firePointerDown(rayCastEntity)
                    break
                case .ended:
                    _upList.append(.Primary)
                    _upMap[button] = frameCount
                    pointer._upList.append(.Primary)
                    pointer._upMap[button] = frameCount
                    pointer.phase = .ended
                    pointer._firePointerUpAndClick(rayCastEntity)
                    break
                case .cancelled:
                    pointer.phase = .cancelled
                    pointer._firePointerExitAndEnter(nil)
                default:
                    break
                }
            }
            pointer._events = []
        } else {
            _ = pointer.deltaPosition.set(x: 0, y: 0)
            pointer.phase = .stationary
            pointer._firePointerDrag()
            pointer._firePointerExitAndEnter(_pointerRayCast(position.x / canvasW, position.y / canvasH))
        }
    }

    private func _pointerRayCast(_ normalizedX: Float, _ normalizedY: Float) -> Entity? {
        nil
    }
}