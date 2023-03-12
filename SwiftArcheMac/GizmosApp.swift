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
        
        let color = Color32(r: 23, g: 12, b: 242)
        Gizmos.addPoint(Vector3(1, 1, 1), color: Color32(r: 123, g: 112, b: 142, a: 255))
        Gizmos.addLine(p0: Vector3(1,1,1), p1: Vector3(2,2,2), color: Color32(r: 23, g: 212, b: 42 , a: 255))
        Gizmos.addTriangle(p0: Vector3(-2,-2,-2), p1: Vector3(-3,-3,-3), p2: Vector3(-2,1,-2),
                           color: Color32(r: 23, g: 12, b: 242 , a: 255))
        
        // Gizmos.addRectangle(width: 2, length: 4, tr: Matrix(), color: color)
        Gizmos.addArrow(posA: Vector3(), posB: Vector3(-1, 1, 1), color: color)
        Gizmos.addStar(p: Vector3(3, 4, 5), size: 2, color: color)
        
        Gizmos.addAABB(box: BoundingBox(Vector3(), Vector3(1, 1, 1)), color: color, renderFlags: .Wireframe)
        Gizmos.addSphere(sphereCenter: Vector3(-2, 2, 3), sphereRadius: 3, color: color, renderFlags: .Wireframe)
        Gizmos.addSphereExt(sphereCenter: Vector3(-5, -2, 3), sphereRadius: 3, color: color, renderFlags: .Wireframe)
        Gizmos.addCapsule(radius: 0.5, height: 1, tr: Matrix(), color: color, renderFlags: .Wireframe)
        Gizmos.addCylinder(radius: 2, height: 5, tr: Matrix(), color: color, renderFlags: .Wireframe)
        Gizmos.addCone(radius: 2, height: 1, tr: Matrix(), color: color, renderFlags: .Wireframe)
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
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        rootEntity.addComponent(GizmosScript.self)
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

