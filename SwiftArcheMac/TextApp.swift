//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class GizmosScript: Script {
    var atlas: MTLFontAtlas!
    
    override func onGUI() {
        Gizmos.addText(string: "This is Gizmos", position: Vector3(-1, -1, 1),
                       color: Color32(r: 124, g: 233, b: 23), size: 3, font: atlas)
    }
}

class TextApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var fontProvider: MTLFontAtlasProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        fontProvider = try! MTLFontAtlasProvider()
        
        let scene = Engine.sceneManager.activeScene!
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
        
        // let scope = Engine.createCaptureScope(name: "sdf text")
        // scope.begin()
        let atlas = try! fontProvider.fontAtlas(descriptor: MTLFontAtlasProvider.defaultAtlasDescriptor)
        // scope.end()
        
        let textEntity = rootEntity.createChild()
        let renderer = textEntity.addComponent(TextRenderer.self)
        renderer.fontAtlas = atlas
        renderer.string = "Hello"
        renderer.color = Color(0.2, 0.4, 0.7)
        renderer.fontSize = 2
        
        let textEntity2 = rootEntity.createChild()
        textEntity2.transform.worldPosition = Vector3(0, 2, -2)
        let renderer2 = textEntity2.addComponent(TextRenderer.self)
        renderer2.fontAtlas = atlas
        renderer2.string = "World"
        renderer2.color = Color(0.4, 0.2, 0.7)
        renderer2.fontSize = 2
        
        rootEntity.addComponent(GizmosScript.self).atlas = atlas
        
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

