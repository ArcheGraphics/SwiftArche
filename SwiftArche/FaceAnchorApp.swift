//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import UIKit
import ARKit
import vox_render
import Math
import simd

fileprivate class ARScript: Script {
    private var _light: Entity?
    private var _avatar: Entity?
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
    
    override func onAwake() {
        let assetURL = Bundle.main.url(forResource: "arkit52", withExtension: "glb", subdirectory: "assets")!
        GLTFLoader.parse(engine, assetURL) { [self] resource in
            let avatar = resource.defaultSceneRoot!
            entity.addChild(avatar)
            _avatar = avatar

            let skinRenderers = avatar.getComponentsIncludeChildren(SkinnedMeshRenderer.self)
            for renderer in skinRenderers {
                if !renderer.blendShapeWeights.isEmpty {
                    _morphRenderer = renderer
                }
            }
        
            _light = entity.createChild("light")
            let directLight = _light!.addComponent(DirectLight.self)
            directLight.intensity = 0.9;
        }
    }
    
    override func onARUpdate(_ deltaTime: Float, _ frame: ARFrame) {
        if let avatar = _avatar, let light = _light {
            light.transform.localMatrix = Matrix(frame.camera.transform)

            for anchor in frame.anchors {
                guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
                let blendShapes = faceAnchor.blendShapes
                for blendShape in blendShapes {
                    _morphRenderer.blendShapeWeights[morphMap[blendShape.key]!] = blendShape.value.floatValue
                }

                var translation = matrix_identity_float4x4
                translation.columns.3.y = 1.0
                translation.columns.3.z = -3.5
                avatar.transform.localMatrix = Matrix(simd_mul(translation, faceAnchor.transform))
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
        let camera = cameraEntity.addComponent(Camera.self)
        engine.arManager!.camera = camera
        
        let arEntity = rootEntity.createChild()
        arEntity.addComponent(ARScript.self)

        engine.run()
    }

    override func viewWillAppear(_ animated: Bool) {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        engine.arManager?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        engine.arManager?.pause()
    }
}

