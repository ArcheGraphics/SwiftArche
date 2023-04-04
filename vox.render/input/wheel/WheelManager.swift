//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import Math

class WheelManager {
    var _delta: Vector3 = .init()
    private var _nativeEvents: [NSEvent] = []

    func _update() {
        var delta = SIMD3<Float>(repeating: 0.0)
        if !_nativeEvents.isEmpty {
            for evt in _nativeEvents {
                delta.x += Float(evt.deltaX)
                delta.y += Float(evt.deltaY)
                delta.z += Float(evt.deltaZ)
            }
            _nativeEvents = []
        }
        _delta = Vector3(delta)
    }

    func _onWheelEvent(_ evt: NSEvent) {
        _nativeEvents.append(evt)
    }
}
