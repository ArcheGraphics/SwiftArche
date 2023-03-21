//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ImGui
import Cocoa

public class UIElement {
    public static func Init(_ engine: Engine) {
        let view = engine.canvas
        let deltaTime = Time.deltaTime
        let io = ImGuiGetIO()!
        io.pointee.DisplaySize.x = Float(view.bounds.size.width)
        io.pointee.DisplaySize.y = Float(view.bounds.size.height)
        let frameBufferScale = Float(view.window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)
        io.pointee.DisplayFramebufferScale = ImVec2(x: frameBufferScale, y: frameBufferScale)
        io.pointee.DeltaTime = deltaTime
    }

    public static func selection(_ title: String, _ names: [String], _ selected: inout Int) {
        // Simple selection popup (if you want to show the current selection inside the Button itself,
        // you may want to build a string using the "###" operator to preserve a constant ID with a variable label)
        if (ImGuiButton("Select \(title) ..", ImVec2(x: 0, y: 0))) {
            ImGuiOpenPopup(title + "select_popup", 0)
        }
        ImGuiSameLine(0, -1)
        ImGuiTextUnformatted(selected == -1 ? "<None>" : names[selected]);
        if (ImGuiBeginPopup(title + "select_popup", 0)) {
            for i in 0..<names.count {
                if (ImGuiSelectable(names[i], false, 0, ImVec2(x: 0, y: 0))) {
                    selected = i
                }
            }
            ImGuiEndPopup()
        }
    }
    
    public static func frameRate() {
        let io = ImGuiGetIO()!
        let avg: Float = (1000.0 / io.pointee.Framerate)
        let fps = io.pointee.Framerate
        ImGuiTextV(String(format: "Application average %.3f ms/frame (%.1f FPS)", avg, fps))
    }
}
