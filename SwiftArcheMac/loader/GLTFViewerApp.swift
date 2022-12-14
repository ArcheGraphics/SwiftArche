//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class GltfViewerApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)

        let scene = engine.sceneManager.activeScene!
        scene.postprocessManager.manualExposure = 1
        scene.shadowCascades = .FourCascades
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(3, 2, 3)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(0.1, 5, 0.1)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight: DirectLight = light.addComponent()
        directLight.shadowType = .SoftLow
        
        let planeEntity = rootEntity.createChild()
        planeEntity.transform.position = Vector3(0, -1, 0)
        let shadowPlane: MeshRenderer = planeEntity.addComponent()
        shadowPlane.mesh = PrimitiveMesh.createPlane(engine, 10, 10)
        let shadowMtl = PBRMaterial(engine)
        shadowMtl.baseColor = Color(0.6, 0.6, 0.6, 1.0)
        shadowMtl.roughness = 1
        shadowMtl.metallic = 0
        shadowMtl.shader[0].setRenderFace(.Double)
        shadowPlane.setMaterial(shadowMtl)
        shadowPlane.castShadows = false
        
        let gltfRoot = rootEntity.createChild()
        let gui: LoaderGUI = gltfRoot.addComponent()
        gui.loaderItem = 8
        gui.camera = camera
        engine.run()
    }
}

