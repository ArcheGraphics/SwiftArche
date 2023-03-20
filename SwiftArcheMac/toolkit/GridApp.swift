//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit
import ImGui

fileprivate class GUI: Script {
    var control: GridControl!
    var speedScale: Float = 8

    override func onGUI() {
        UIElement.Init(engine)

        ImGuiNewFrame()
        ImGuiSliderFloat("Grid primary Scale", &control.material.primaryScale, 1.0, 20.0, nil, 1)
        ImGuiSliderFloat("Grid secondary Scale", &control.material.secondaryScale, 1.0, 20.0, nil, 1)
        ImGuiSliderFloat("Grid Intensity", &control.material.gridIntensity, 0.1, 1.0, nil, 1)
        ImGuiSliderFloat("Axis Intensity", &control.material.axisIntensity, 0.1, 1.0, nil, 1)
        ImGuiSliderFloat("Speed Scale", &speedScale, 0.1, 16.0, nil, 1)
        // Rendering
        ImGuiRender()
    }
    
    override func onUpdate(_ deltaTime: Float) {
        control.distance = control.camera!.entity.transform.worldPosition.lengthSquared() / speedScale
    }
}

class GridApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)

        let scene = engine.sceneManager.activeScene!
        scene.background.solidColor = Color(0, 0, 0, 1)
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        
        let rootEntity = scene.createRootEntity()
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera = cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let gui = rootEntity.addComponent(GUI.self)
        let gridControl = rootEntity.addComponent(GridControl.self)
        gridControl.camera = camera
        gui.control = gridControl
        
        let cubeEntity = rootEntity.createChild()
        let renderer = cubeEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCuboid(engine)
        let material = PBRMaterial(engine)
        material.baseColor = Color(0.7, 0.0, 0.0)
        renderer.setMaterial(material)
        
        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

