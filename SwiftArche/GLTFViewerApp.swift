//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import UIKit
import ARKit
import vox_render
import vox_math

fileprivate class ARScript: Script {
    private var _isInitialize: Bool = false

    override func onARUpdate(_ deltaTime: Float, _ frame: ARFrame) {
        if !_isInitialize {
            _isInitialize = true
            let assetURL = Bundle.main.url(forResource: "SciFiHelmet",
                    withExtension: "gltf",
                    subdirectory: "glTF")!
            GLTFLoader.parse(engine, assetURL) { [self] resource in
                entity.clearChildren()
                entity.addChild(resource.defaultSceneRoot)
                let renderers: [Renderer] = resource.defaultSceneRoot.getComponentsIncludeChildren()
                var bounds = BoundingBox()
                for renderer in renderers {
                    bounds = BoundingBox.merge(box1: bounds, box2: renderer.bounds)
                }
                let scale = 0.1 / bounds.getExtent().internalValue.max()
                
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.5
                entity.transform.localMatrix = Matrix(simd_mul(frame.camera.transform, translation))
                resource.defaultSceneRoot.transform.scale *= scale
            }
        }
    }
}

class GltfViewerApp: UIViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        engine.initArSession()
        iblBaker = IBLBaker(engine)

        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        let camera: Camera = cameraEntity.addComponent()
        engine.arManager!.camera = camera

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(0.1, 5, 0.1)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight: DirectLight = light.addComponent()
        directLight.shadowType = .SoftLow
        
        let arEntity = rootEntity.createChild()
        let _: ARScript = arEntity.addComponent()

        engine.run()
    }

    override func viewWillAppear(_ animated: Bool) {
        engine.arManager?.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        engine.arManager?.pause()
    }
}

