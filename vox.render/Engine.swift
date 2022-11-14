//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Logging

let logger = Logger(label: "com.arche.main")

public class Engine {
    let _componentsManager: ComponentsManager = ComponentsManager()
    let _lightManager = LightManager()
    var sceneManager: SceneManager!
    var canvas: Canvas
    var device: MTLDevice
    var _macroCollection: ShaderMacroCollection = ShaderMacroCollection();

    init(canvas: Canvas) {
        self.canvas = canvas
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        self.device = device
        sceneManager = SceneManager(engine: self)
    }
}