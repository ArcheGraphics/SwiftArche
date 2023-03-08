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

fileprivate class GizmosScript: Script {
    override func onGUI() {
        UIElement.Init(engine)

        ImGuiNewFrame()
        ImGuiSliderFloat("gizmo point size", &Gizmos.pointSize, 5.0, 30.0, nil, 1)
        // Rendering
        ImGuiRender()
        
        Gizmos.addPoint(Vector3(1, 1, 1), color: Color32(r: 123, g: 112, b: 142, a: 255))
        Gizmos.addLine(p0: Vector3(1,1,1), p1: Vector3(2,2,2), color: Color32(r: 23, g: 212, b: 42 , a: 255))
        Gizmos.addTriangle(p0: Vector3(2,2,2), p1: Vector3(3,3,3), p2: Vector3(0,1,0),
                           color: Color32(r: 23, g: 12, b: 242 , a: 255))
        
        Gizmos.addArrow(posA: Vector3(), posB: Vector3(-1, 1, 1), color: Color32(r: 23, g: 12, b: 242))
    }
}

class GizmosApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(2, 2, 2)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera = cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        Gizmos.set(camera: camera)
        rootEntity.addComponent(GizmosScript.self)
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        engine.run()
    }
}

