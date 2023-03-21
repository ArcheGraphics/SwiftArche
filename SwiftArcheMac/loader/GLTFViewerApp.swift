//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

class GltfViewerApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker()

        let scene = Engine.sceneManager.activeScene!
        scene.postprocessManager.manualExposure = 1
        scene.shadowCascades = .FourCascades
        let hdr = Engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(3, 2, 3)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera = cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(0.1, 5, 0.1)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = .SoftLow
        
        let planeEntity = rootEntity.createChild()
        planeEntity.transform.position = Vector3(0, -1, 0)
        let shadowPlane = planeEntity.addComponent(MeshRenderer.self)
        shadowPlane.mesh = PrimitiveMesh.createPlane(width: 10, height: 10)
        let shadowMtl = PBRMaterial()
        shadowMtl.baseColor = Color(0.6, 0.6, 0.6, 1.0)
        shadowMtl.roughness = 1
        shadowMtl.metallic = 0
        shadowMtl.shader[0].setRenderFace(.Double)
        shadowPlane.setMaterial(shadowMtl)
        shadowPlane.castShadows = false
        
        let gltfRoot = rootEntity.createChild()
        let gui = gltfRoot.addComponent(LoaderGUI.self)
        gui.loaderItem = 8
        gui.camera = camera
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

