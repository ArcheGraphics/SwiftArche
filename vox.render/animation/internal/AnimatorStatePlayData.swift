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

    func update(isBackwards: Bool) {
        var time = frameTime!
        let duration = state._getDuration();
        playState = AnimatorStatePlayState.Playing;
        if (state.wrapMode == WrapMode.Loop) {
            time = duration != 0 ? time.truncatingRemainder(dividingBy: duration) : 0;
        } else {
            if (abs(time) > duration) {
                time = time < 0 ? -duration : duration;
                playState = AnimatorStatePlayState.Finished;
            }
        }

        if (isBackwards && time == 0) {
            clipTime = state.clipEndTime * state.clip!.length;
        } else {
            if time < 0 {
                time += duration
            }
            clipTime = time + state.clipStartTime * state.clip!.length;
        }
    }
}
