//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ImGui

public class UIElement {
    public static func selection(_ title: String, _ names: [String], _ selected:inout Int) {
        // Simple selection popup (if you want to show the current selection inside the Button itself,
        // you may want to build a string using the "###" operator to preserve a constant ID with a variable label)
        if (ImGuiButton("Select..", ImVec2(x: 0, y: 0))) {
            ImGuiOpenPopup("my_select_popup", 0)
        }
        ImGuiSameLine(0, -1)
        ImGuiTextUnformatted(selected == -1 ? "<None>" : names[selected]);
        if (ImGuiBeginPopup("my_select_popup", 0)) {
            ImGuiTextV(title)
            ImGuiSeparator()
            for i in 0..<names.count {
                if (ImGuiSelectable(names[i], false, 0, ImVec2(x: 0, y: 0))) {
                    selected = i
                }
            }
            ImGuiEndPopup()
        }
    }
}
