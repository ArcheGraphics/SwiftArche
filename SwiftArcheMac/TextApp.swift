//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class TextApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var fontProvider: MTLFontAtlasProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        fontProvider = try! MTLFontAtlasProvider(engine: engine)
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)
        
        // let scope = engine.createCaptureScope(name: "sdf text")
        // scope.begin()
        let atlas = try! fontProvider.fontAtlas(descriptor: MTLFontAtlasProvider.defaultAtlasDescriptor)
        // scope.end()
        
        let textEntity = rootEntity.createChild()
        let renderer = textEntity.addComponent(TextRenderer.self)
        renderer.fontAtlas = atlas
        renderer.string = "Hello World"
        renderer.color = Color(0.2, 0.4, 0.7)
        renderer.fontSize = 2
        
        engine.run()
    }
}

