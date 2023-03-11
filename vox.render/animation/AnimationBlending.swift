//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class AnimationBlending: AnimationState {
    public var threshold: Float {
        get {
            (_nativeState as! CAnimatorBlending).threshold
        }
        set {
            (_nativeState as! CAnimatorBlending).threshold = newValue
        }
    }

    public override init() {
        super.init()
        _nativeState = CAnimatorBlending()
    }
}
