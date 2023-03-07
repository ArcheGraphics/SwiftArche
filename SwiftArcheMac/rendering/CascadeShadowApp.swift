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

fileprivate class GUI: Script {
    var rotation: Rotation!
    var directLight: DirectLight!
    var planeRenderer: MeshRenderer!
    var boxRenderers: [MeshRenderer] = []
    var visualMaterial: CSSMVisualMaterial!
    var planeMaterial: Material!
    var boxMaterial: Material!
    private var _debugMode: Bool = false

    override func onAwake() {
        visualMaterial = CSSMVisualMaterial(entity.engine)
    }

    private var shadowType: Int {
        get {
            directLight.shadowType.rawValue
        }
        set {
            directLight.shadowType = ShadowType(rawValue: newValue)!
        }
    }

    private var cascadeMode: Int {
        get {
            switch scene.shadowCascades {
            case .NoCascades:
                return 0
            case .TwoCascades:
                return 1
            case .FourCascades:
                return 2
            }
        }
        set {
            switch newValue {
            case 0:
                scene.shadowCascades = .NoCascades
                break
            case 1:
                scene.shadowCascades = .TwoCascades
                break
            case 2:
                scene.shadowCascades = .FourCascades
                break
            default:
                break
            }
        }
    }

    private var resolution: Int {
        get {
            scene.shadowResolution.rawValue
        }
        set {
            scene.shadowResolution = ShadowResolution(rawValue: newValue)!
        }
    }

    private var pause: Bool {
        get {
            rotation.pause
        }
        set {
            rotation.pause = newValue
        }
    }

    private var debugMode: Bool {
        get {
            _debugMode
        }
        set {
            _debugMode = newValue
            if newValue {
                planeRenderer.setMaterial(visualMaterial)
                for boxRenderer in boxRenderers {
                    boxRenderer.setMaterial(visualMaterial)
                }
            } else {
                planeRenderer.setMaterial(planeMaterial)
                for boxRenderer in boxRenderers {
                    boxRenderer.setMaterial(boxMaterial)
                }
            }
        }
    }

    private var shadowFourCascadeSplitRatioX: Float {
        get {
            scene.shadowFourCascadeSplits.x
        }
        set {
            scene.shadowFourCascadeSplits = Vector3(newValue, scene.shadowFourCascadeSplits.y, scene.shadowFourCascadeSplits.z)
        }
    }

    private var shadowFourCascadeSplitRatioY: Float {
        get {
            scene.shadowFourCascadeSplits.y
        }
        set {
            scene.shadowFourCascadeSplits = Vector3(scene.shadowFourCascadeSplits.x, newValue, scene.shadowFourCascadeSplits.z)
        }
    }

    private var shadowFourCascadeSplitRatioZ: Float {
        get {
            scene.shadowFourCascadeSplits.z
        }
        set {
            scene.shadowFourCascadeSplits = Vector3(scene.shadowFourCascadeSplits.x, scene.shadowFourCascadeSplits.y, newValue)
        }
    }

    override func onGUI() {
        UIElement.Init(engine)

        ImGuiNewFrame()
        ImGuiCheckbox("pause", &pause)
        ImGuiCheckbox("debugMode", &debugMode)
        ImGuiSliderFloat("shadowBias", &directLight.shadowBias, 0.0, 1.0, nil, 1)
        ImGuiSliderFloat("shadowNormalBias", &directLight.shadowNormalBias, 0.0, 1.0, nil, 1)
        ImGuiSliderFloat("shadowStrength", &directLight.shadowStrength, 0.0, 1.0, nil, 1)
        UIElement.selection("shadowType", ["None", "Hard", "SoftLow", "VerySoft"], &shadowType)
        UIElement.selection("cascadeMode", ["NoCascades", "TwoCascades", "FourCascades"], &cascadeMode)
        UIElement.selection("resolution", ["Low", "Medium", "High", "VeryHigh"], &resolution)
        ImGuiSliderFloat("shadowTwoCascadeSplitRatio", &scene.shadowTwoCascadeSplits, 0.0, 1.0, nil, 1)
        ImGuiSliderFloat("shadowFourCascadeSplitRatioX", &shadowFourCascadeSplitRatioX, 0.0, 1.0, nil, 1)
        ImGuiSliderFloat("shadowFourCascadeSplitRatioY", &shadowFourCascadeSplitRatioY, 0.0, 1.0, nil, 1)
        ImGuiSliderFloat("shadowFourCascadeSplitRatioZ", &shadowFourCascadeSplitRatioZ, 0.0, 1.0, nil, 1)

        // Rendering
        ImGuiRender()
    }
}

fileprivate class Rotation: Script {
    var pause = true
    private var _time: Float = 0
    private var _center = Vector3()

    override func onUpdate(_ deltaTime: Float) {
        if (!pause) {
            _time += deltaTime
            entity.transform.position = Vector3(10 * cos(_time), 10, 10 * sin(_time))
            entity.transform.lookAt(targetPosition: _center)
        }
    }
}

fileprivate class CSSMVisualMaterial: BaseMaterial {
    private var _baseColor = Color(1, 1, 1, 1)

    /// Base color.
    public var baseColor: Color {
        get {
            _baseColor.toGamma()
        }
        set {
            _baseColor = newValue
            shaderData.setData(CSSMVisualMaterial._baseColorProp, newValue.toLinear())
        }
    }
    
    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("app.shader"), "vertex_unlit", "shadowMap_visual"))
        shaderData.enableMacro(NEED_WORLDPOS.rawValue)
        shaderData.setData(CSSMVisualMaterial._baseColorProp, _baseColor)
    }
}

class CascadeShadowApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        scene.shadowResolution = ShadowResolution.High
        scene.shadowDistance = 300
        scene.shadowCascades = ShadowCascadesMode.FourCascades
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        
        let rootEntity = scene.createRootEntity()
        let gui = rootEntity.addComponent(GUI.self)
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(0, 10, 50)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera = cameraEntity.addComponent(Camera.self)
        camera.farClipPlane = 1000
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(10, 10, 0)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        gui.rotation = light.addComponent(Rotation.self)
        directLight.shadowStrength = 1.0
        directLight.shadowType = ShadowType.SoftLow
        gui.directLight = directLight

        // Create plane
        let planeEntity = rootEntity.createChild("PlaneEntity")
        let planeRenderer = planeEntity.addComponent(MeshRenderer.self)
        planeRenderer.mesh = PrimitiveMesh.createPlane(engine, width: 10, height: 400)
        gui.planeRenderer = planeRenderer

        let planeMaterial = PBRMaterial(engine)
        planeMaterial.baseColor = Color(1.0, 0.2, 0, 1.0)
        planeMaterial.roughness = 0.8
        planeMaterial.metallic = 0.2
        planeMaterial.shader[0].setRenderFace(RenderFace.Double)
        gui.planeMaterial = planeMaterial

        planeRenderer.setMaterial(planeMaterial)
        planeRenderer.castShadows = false
        planeRenderer.receiveShadows = true
        
        // Create box
        let boxMesh = PrimitiveMesh.createCuboid(engine, width: 2.0, height: 2.0, depth: 2.0)
        let boxMaterial = PBRMaterial(engine)
        boxMaterial.roughness = 0.2
        boxMaterial.metallic = 1
        gui.boxMaterial = boxMaterial
        for i in 0..<40 {
            let boxEntity = rootEntity.createChild("BoxEntity")
            boxEntity.transform.position = Vector3(0, 2, Float(i * 10) - 200)

            let boxRenderer = boxEntity.addComponent(MeshRenderer.self)
            boxRenderer.mesh = boxMesh
            boxRenderer.setMaterial(boxMaterial)
            gui.boxRenderers.append(boxRenderer)
        }

        engine.run()
    }
}
