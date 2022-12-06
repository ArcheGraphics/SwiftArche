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

struct GLTFInfo {
    let name: String
    let ext: String
    let dir: String

    init(_ name: String, _ ext: String, _ dir: String) {
        self.name = name
        self.ext = ext
        self.dir = dir
    }
}

class LoaderGUI: Script {
    var currentItem: Int = 0
    let gltfInfo = [
        GLTFInfo("Box", "glb", "glTF-Sample-Models/2.0/Box/glTF-Binary"),
    ]

    private var loaderItem: Int {
        get {
            currentItem
        }
        set {
            if newValue != currentItem {
                currentItem = newValue
                let assetURL = Bundle.main.url(forResource: gltfInfo[newValue].name,
                                               withExtension: gltfInfo[newValue].ext,
                                               subdirectory: gltfInfo[newValue].dir)!
                GLTFLoader.parse(engine, assetURL) { [self] resource in
                    entity.clearChildren()
                    entity.addChild(resource.defaultSceneRoot)
                }
            }
        }
    }

    override func onUpdate(_ deltaTime: Float) {
        UIElement.Init(engine.canvas, deltaTime)

        ImGuiNewFrame()

        var names: [String] = []
        for info in gltfInfo {
            names.append(info.name)
        }
        UIElement.selection("GLTF Name", names, &loaderItem)
        UIElement.frameRate()
        // Rendering
        ImGuiRender()
    }
}
