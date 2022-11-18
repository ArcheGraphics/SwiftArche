//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import UIKit
import ARKit
import vox_render

class PrimitiveApp: UIViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)

        engine = Engine(canvas: canvas)
        engine.initArSession()

        let scene = engine.sceneManager.activeScene!
        let root = scene.createRootEntity()
    }
}

