//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

internal class AnimatorStatePlayData {
    var state: AnimatorState!
    var stateData: AnimatorStateData!
    var frameTime: Float!
    var playState: AnimatorStatePlayState!
    var clipTime: Float!
    var currentEventIndex: Int!

    func reset(_ state: AnimatorState, _ stateData: AnimatorStateData, _ offsetFrameTime: Float) {
        self.state = state
        self.frameTime = offsetFrameTime
        self.stateData = stateData
        self.playState = AnimatorStatePlayState.UnStarted
        self.clipTime = self.state.clipStartTime
        self.currentEventIndex = 0
    }

    func update() {
        var time = frameTime
        let duration = state.clipEndTime - state.clipStartTime
        self.playState = AnimatorStatePlayState.Playing
        if (time! > duration) {
            if (state.wrapMode == WrapMode.Loop) {
                time = time!.truncatingRemainder(dividingBy: duration)
            } else {
                time = duration
                self.playState = AnimatorStatePlayState.Finished
            }
        }
        self.clipTime = time! + self.state.clipStartTime
    }
}
