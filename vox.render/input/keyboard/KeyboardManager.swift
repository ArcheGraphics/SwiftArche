//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import Math

class KeyboardManager {
    var _curHeldDownKeyToIndexMap: [Keys: Int] = [:]
    var _upKeyToFrameCountMap: [Keys: UInt64] = [:]
    var _downKeyToFrameCountMap: [Keys: UInt64] = [:]
    
    var _curFrameHeldDownList: DisorderedArray<Keys> = DisorderedArray()
    var _curFrameDownList: DisorderedArray<Keys> = DisorderedArray()
    var _curFrameUpList: DisorderedArray<Keys> = DisorderedArray()
    
    private var _nativeEvents: [NSEvent] = []
    
    func _update(_ frameCount: UInt64) {
        _curFrameDownList.count = 0
        _curFrameUpList.count = 0
        if (_nativeEvents.count > 0) {
            for evt in _nativeEvents {
                let codeKey = Keys(rawValue: evt.keyCode)!
                switch (evt.type) {
                case .keyDown:
                    // Filter the repeated triggers of the keyboard.
                    if (_curHeldDownKeyToIndexMap[codeKey] == nil) {
                        _curFrameDownList.add(codeKey)
                        _curFrameHeldDownList.add(codeKey)
                        _curHeldDownKeyToIndexMap[codeKey] = _curFrameHeldDownList.count - 1
                        _downKeyToFrameCountMap[codeKey] = frameCount
                    }
                    break
                case .keyUp:
                    let delIndex = _curHeldDownKeyToIndexMap[codeKey]
                    if (delIndex != nil) {
                        _curHeldDownKeyToIndexMap.removeValue(forKey: codeKey)
                        let swapCode = _curFrameHeldDownList.deleteByIndex(delIndex!)
                        if swapCode != nil {
                            _curHeldDownKeyToIndexMap[swapCode!] = delIndex
                        }
                    }
                    _curFrameUpList.add(codeKey)
                    _upKeyToFrameCountMap[codeKey] = frameCount
                    break
                default:
                    break
                }
            }
            _nativeEvents = []
        }
    }
    
    func _onKeyEvent(_ evt: NSEvent) {
        _nativeEvents.append(evt)
    }
}
