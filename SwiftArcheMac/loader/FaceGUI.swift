//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import ImGui
import Math
import vox_render
import vox_toolkit

class FaceGUI: Script {
    var morphRenderer: SkinnedMeshRenderer!
    // Map from Arkit ARFaceAnchor.BlendShapeLocation(https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation)
    // to Model morph index
    var morphNameMap: [String: Int] = [
        "browDownLeft": 51,
        "browDownRight": 50,
        "browInnerUp": 49,
        "browOuterUpLeft": 48,
        "browOuterUpRight": 47,
        "cheekPuff": 46,
        "cheekSquintLeft": 45,
        "cheekSquintRight": 44,
        "eyeBlinkLeft": 43,
        "eyeBlinkRight": 42,
        "eyeLookDownLeft": 41,
        "eyeLookDownRight": 40,
        "eyeLookInLeft": 39,
        "eyeLookInRight": 38,
        "eyeLookOutLeft": 37,
        "eyeLookOutRight": 36,
        "eyeLookUpLeft": 35,
        "eyeLookUpRight": 34,
        "eyeSquintLeft": 33,
        "eyeSquintRight": 32,
        "eyeWideLeft": 31,
        "eyeWideRight": 30,
        "jawForward": 29,
        "jawLeft": 28,
        "jawOpen": 27,
        "jawRight": 26,
        "mouthClose": 25,
        "mouthDimpleLeft": 24,
        "mouthDimpleRight": 23,
        "mouthFrownLeft": 22,
        "mouthFrownRight": 21,
        "mouthFunnel": 20,
        "mouthLeft": 19,
        "mouthLowerDownLeft": 18,
        "mouthLowerDownRight": 17,
        "mouthPressLeft": 16,
        "mouthPressRight": 15,
        "mouthPucker": 14,
        "mouthRight": 13,
        "mouthRollLower": 12,
        "mouthRollUpper": 11,
        "mouthShrugLower": 10,
        "mouthShrugUpper": 9,
        "mouthSmileLeft": 8,
        "mouthSmileRight": 7,
        "mouthStretchLeft": 6,
        "mouthStretchRight": 5,
        "mouthUpperUpLeft": 4,
        "mouthUpperUpRight": 3,
        "noseSneerLeft": 2,
        "noseSneerRight": 1,
        "tongueOut": 0,
    ]

    override func onGUI() {
        UIElement.Init()

        ImGuiNewFrame()
        for morph in morphNameMap {
            ImGuiSliderFloat(morph.key, &morphRenderer.blendShapeWeights[morph.value], 0.0, 1.0, nil, 1)
        }

        ImGuiSeparator()
        ImGuiSliderFloat("Manual Exposure", &scene.postprocessManager.manualExposure, 0.0, 1.0, nil, 1)
        UIElement.frameRate()
        // Rendering
        ImGuiRender()
    }
}
