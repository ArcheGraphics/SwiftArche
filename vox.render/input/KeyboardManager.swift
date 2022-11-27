//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_math
import Carbon

class KeyboardManager {
    var _curHeldDownKeyToIndexMap: [Keys: Int] = [:]
    var _upKeyToFrameCountMap: [Keys: UInt64] = [:]
    var _downKeyToFrameCountMap: [Keys: UInt64] = [:]
    
    var _curFrameHeldDownList: [Keys] = []
    var _curFrameDownList: [Keys] = []
    var _curFrameUpList: [Keys] = []
    
    private var _nativeEvents: [NSEvent] = []
    
    func _update(_ frameCount: UInt64) {
        _curFrameDownList = []
        _curFrameUpList = []
        if (_nativeEvents.count > 0) {
            for evt in _nativeEvents {
                let codeKey = Keys(rawValue: evt.keyCode)!
                switch (evt.type) {
                case .keyDown:
                    // Filter the repeated triggers of the keyboard.
                    if (_curHeldDownKeyToIndexMap[codeKey] == nil) {
                        _curFrameDownList.append(codeKey)
                        _curFrameHeldDownList.append(codeKey)
                        _curHeldDownKeyToIndexMap[codeKey] = _curFrameHeldDownList.count - 1
                        _downKeyToFrameCountMap[codeKey] = frameCount
                    }
                    break
                case .keyUp:
                    let delIndex = _curHeldDownKeyToIndexMap[codeKey]
                    if (delIndex != nil) {
                        _curHeldDownKeyToIndexMap[codeKey] = nil
                        _curFrameHeldDownList.remove(at: delIndex!)
                    }
                    _curFrameUpList.append(codeKey)
                    _upKeyToFrameCountMap[codeKey] = frameCount
                    break
                default:
                    break
                }
            }
            _nativeEvents = []
        }
    }
}
