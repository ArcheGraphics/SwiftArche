//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class Engine {
    let _componentsManager: ComponentsManager = ComponentsManager()
    var sceneManager: SceneManager!

    init() {
        sceneManager = SceneManager(engine: self)
    }
}