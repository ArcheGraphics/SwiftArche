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
    private var _morphRenderer: SkinnedMeshRenderer!
    var morphMap: [ARFaceAnchor.BlendShapeLocation : Int] = [
        .browDownLeft:        51,
        .browDownRight:       50,
        .browInnerUp:         49,
        .browOuterUpLeft:     48,
        .browOuterUpRight:    47,
        .cheekPuff:           46,
        .cheekSquintLeft:     45,
        .cheekSquintRight:    44,
        .eyeBlinkLeft:        43,
        .eyeBlinkRight:       42,
        .eyeLookDownLeft:     41,
        .eyeLookDownRight:    40,
        .eyeLookInLeft:       39,
        .eyeLookInRight:      38,
        .eyeLookOutLeft:      37,
        .eyeLookOutRight:     36,
        .eyeLookUpLeft:       35,
        .eyeLookUpRight:      34,
        .eyeSquintLeft:       33,
        .eyeSquintRight:      32,
        .eyeWideLeft:         31,
        .eyeWideRight:        30,
        .jawForward:          29,
        .jawLeft:             28,
        .jawOpen:             27,
        .jawRight:            26,
        .mouthClose:          25,
        .mouthDimpleLeft:     24,
        .mouthDimpleRight:    23,
        .mouthFrownLeft:      22,
        .mouthFrownRight:     21,
        .mouthFunnel:         20,
        .mouthLeft:           19,
        .mouthLowerDownLeft:  18,
        .mouthLowerDownRight: 17,
        .mouthPressLeft:      16,
        .mouthPressRight:     15,
        .mouthPucker:         14,
        .mouthRight:          13,
        .mouthRollLower:      12,
        .mouthRollUpper:      11,
        .mouthShrugLower:     10,
        .mouthShrugUpper:      9,
        .mouthSmileLeft:       8,
        .mouthSmileRight:      7,
        .mouthStretchLeft:     6,
        .mouthStretchRight:    5,
        .mouthUpperUpLeft:     4,
        .mouthUpperUpRight:    3,
        .noseSneerLeft:        2,
        .noseSneerRight:       1,
        .tongueOut:            0,
    ]
    override func onARUpdate(_ deltaTime: Float, _ frame: ARFrame) {
        if !_isInitialize {
            let assetURL = Bundle.main.url(forResource: "ARkit_with_eyegazin", withExtension: "glb", subdirectory: "assets")!
            GLTFLoader.parse(engine, assetURL) { [self] resource in
                entity.addChild(resource.defaultSceneRoot)
                
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.5
                translation.columns.3.y = -0.5
                entity.transform.localMatrix = Matrix(simd_mul(frame.camera.transform, translation))
                
                let skinRenderers: [SkinnedMeshRenderer] = resource.defaultSceneRoot.getComponentsIncludeChildren()
                for renderer in skinRenderers {
                    if !renderer.blendShapeWeights.isEmpty {
                        _morphRenderer = renderer
                    }
                }
                _isInitialize = true
            }
        }
        
        if _isInitialize {
            for anchor in frame.anchors {
                guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
                let blendShapes = faceAnchor.blendShapes
                for blendShape in blendShapes {
                    _morphRenderer.blendShapeWeights[morphMap[blendShape.key]!] = blendShape.value.floatValue
                }
            }

        }
    }
}

class FaceAnchorApp: UIViewController {
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
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        engine.arManager?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        engine.arManager?.pause()
    }
}

