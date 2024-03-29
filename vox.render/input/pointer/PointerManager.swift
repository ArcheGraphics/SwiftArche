//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

class PointerManager {
    private var _ray = Ray()
    var firePointerEvent: Bool = true

    // MARK: - IOS

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

        func fireiOSPointerEvent() {}
    #else

        // MARK: - MACOS

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

        func fireMacPointerEvent() {
            let raycast = { [self] (event: NSEvent) -> HitResult? in
                let cameras = Engine.sceneManager.activeScene?._activeCameras
                if let cameras = cameras {
                    for camera in cameras {
                        if !camera.enabled || camera.renderTarget != nil {
                            continue
                        }
                        _ = camera.screenPointToRay(event.screenPoint(Engine.canvas), _ray)
                        return Engine.physicsManager.raycast(_ray, distance: Float.greatestFiniteMagnitude, layerMask: camera.cullingMask)
                    }
                }
                return nil
            }

            // fire event
            for event in _pointers {
                switch event.type {
                case .leftMouseDown, .rightMouseDown, .otherMouseDown,
                     .leftMouseUp, .rightMouseUp, .otherMouseUp:
                    if let hitResult = raycast(event) {
                        let scripts = hitResult.entity!._scripts
                        for i in 0 ..< scripts.count {
                            let script = scripts.get(i)!
                            if !script._waitHandlingInValid {
                                script.onPointerCast(hitResult, event.type.rawValue)
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
    #endif

    func _update() {
        _pointers = _nativeEvents
        _nativeEvents = []

        if firePointerEvent {
            #if os(iOS)
                fireiOSPointerEvent()
            #else
                fireMacPointerEvent()
            #endif
        }
    }
}
