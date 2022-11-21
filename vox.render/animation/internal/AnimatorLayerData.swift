//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

internal class AnimatorLayerData {
    var animatorStateDataMap: [String: AnimatorStateData] = [:]
    var srcPlayData: AnimatorStatePlayData = AnimatorStatePlayData()
    var destPlayData: AnimatorStatePlayData = AnimatorStatePlayData()
    var layerState: LayerState = LayerState.Standby
    var crossCurveMark: Int = 0
    var manuallyTransition: AnimatorStateTransition = AnimatorStateTransition()
    var crossFadeTransition: AnimatorStateTransition!

    func switchPlayData() {
        let srcPlayData = destPlayData
        let switchTemp = srcPlayData
        self.srcPlayData = srcPlayData
        destPlayData = switchTemp
    }
}
