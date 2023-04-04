//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ARKit
import Math
import UIKit
import vox_render

private class ARScript: Script {
    private var _isInitialize: Bool = false

    override func onARUpdate(_: Float, _ frame: ARFrame) {
        if !_isInitialize {
            _isInitialize = true
            let assetURL = Bundle.main.url(forResource: "SciFiHelmet",
                                           withExtension: "gltf",
                                           subdirectory: "glTF")!
            GLTFLoader.parse(assetURL) { [self] resource in
                entity.clearChildren()
                entity.addChild(resource.defaultSceneRoot)
                let renderers = resource.defaultSceneRoot.getComponentsIncludeChildren(Renderer.self)
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
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        Engine.initArSession()
        iblBaker = IBLBaker()

        let scene = Engine.sceneManager.activeScene!
        let hdr = Engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        let camera = cameraEntity.addComponent(Camera.self)
        Engine.arManager!.camera = camera

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(0.1, 5, 0.1)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = .SoftLow

        let arEntity = rootEntity.createChild()
        arEntity.addComponent(ARScript.self)

        Engine.run()
    }

    override func viewWillAppear(_: Bool) {
        Engine.arManager?.run()
    }

    override func viewWillDisappear(_: Bool) {
        Engine.arManager?.pause()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Engine.destroy()
    }
}
