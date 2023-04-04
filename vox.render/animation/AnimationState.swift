//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class AnimationState {
    public enum BlendMode: UInt8 {
        case Normal = 0
        case Additive = 1
        case NoBlend = 2
    }

    public var blendMode: BlendMode {
        get {
            BlendMode(rawValue: _nativeState.blendMode)!
        }
        set {
            _nativeState.blendMode = newValue.rawValue
        }
    }

    public var weight: Float {
        get {
            _nativeState.weight
        }
        set {
            _nativeState.weight = newValue
        }
    }

    var _nativeState: CAnimationState!

    public func addChild(state: AnimationState) {
        _nativeState.addChild(state._nativeState)
    }

    public func removeChild(state: AnimationState) {
        _nativeState.removeChild(state._nativeState)
    }

    public func setJointMasks(_ mask: Float, root: String? = nil) {
        _nativeState.setJointMasks(mask, root)
    }
}
