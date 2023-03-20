//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

class GridApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()
        
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera = cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let gridControl = rootEntity.addComponent(GridControl.self)
        gridControl.camera = camera
        
        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

