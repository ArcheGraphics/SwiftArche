//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import ImGui

class FaceGUI: Script {
    var morphRenderer: SkinnedMeshRenderer!
    var morphName: [String] = []
    
    override func onUpdate(_ deltaTime: Float) {
        UIElement.Init(engine.canvas, deltaTime)

        ImGuiNewFrame()
        for i in 0..<morphName.count {
            ImGuiSliderFloat(morphName[i], &morphRenderer.blendShapeWeights[i], 0.0, 1.0, nil, 1)
        }

        ImGuiSeparator()
        ImGuiSliderFloat("Manual Exposure", &scene.postprocessManager.manualExposure, 0.0, 1.0, nil, 1)
        UIElement.frameRate()
        // Rendering
        ImGuiRender()
    }
}
