//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class FaceMorphApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)

        let scene = engine.sceneManager.activeScene!
        scene.shadowCascades = .FourCascades
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(0, 1, 6)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let control: OrbitControl = cameraEntity.addComponent()
        control.target = Vector3(0, 1, 0)
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(0.1, 5, 0.1)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()

        let gltfRoot = rootEntity.createChild()
        let assetURL = Bundle.main.url(forResource: "arkit52", withExtension: "glb", subdirectory: "assets")!
        GLTFLoader.parse(engine, assetURL) { [] resource in
            let faceGUI: FaceGUI = gltfRoot.addComponent()
            gltfRoot.addChild(resource.defaultSceneRoot)
            
            let skinRenderers: [SkinnedMeshRenderer] = gltfRoot.getComponentsIncludeChildren()
            for renderer in skinRenderers {
                if !renderer.blendShapeWeights.isEmpty {
                    faceGUI.morphRenderer = renderer
                    faceGUI.morphRenderer.entity.transform.worldPosition = Vector3()
                }
            }
        }

        engine.run()
    }
}

