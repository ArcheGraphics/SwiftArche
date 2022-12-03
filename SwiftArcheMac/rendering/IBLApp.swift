//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import ModelIO
import ImGui

fileprivate class GUI: Script {
    override func onUpdate(_ deltaTime: Float) {
        let view = engine.canvas
        let io = ImGuiGetIO()!
        io.pointee.DisplaySize.x = Float(view.bounds.size.width)
        io.pointee.DisplaySize.y = Float(view.bounds.size.height)
        let frameBufferScale = Float(view.window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)
        io.pointee.DisplayFramebufferScale = ImVec2(x: frameBufferScale, y: frameBufferScale)
        io.pointee.DeltaTime = deltaTime

        ImGuiNewFrame()
        ImGuiSliderFloat("Manual Exposure", &scene.postprocessManager.manualExposure, 0.0, 1.0, nil, 1)
        ImGuiSliderFloat("Exposure Key", &scene.postprocessManager.exposureKey, 0.0, 1.0, nil, 1)
        // Rendering
        ImGuiRender()
    }
}

fileprivate struct Material {
    var name: String = ""
    var baseColor: Color = Color()
    var roughness: Float = 0
    var metallic: Float = 0

    init() {
    }

    init(_ n: String, _ c: Color, _ r: Float, _ m: Float) {
        name = n
        roughness = r
        metallic = m
        baseColor = c
    }
}

class IblApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    private var _materials: [Material] = [
        Material("Gold", Color(1.0, 0.765557, 0.336057, 1.0), 0.1, 1.0),
        Material("Copper", Color(0.955008, 0.637427, 0.538163, 1.0), 0.1, 1.0),
        Material("Chromium", Color(0.549585, 0.556114, 0.554256, 1.0), 0.1, 1.0),
        Material("Nickel", Color(0.659777, 0.608679, 0.525649, 1.0), 0.1, 1.0),
        Material("Titanium", Color(0.541931, 0.496791, 0.449419, 1.0), 0.1, 1.0),
        Material("Cobalt", Color(0.662124, 0.654864, 0.633732, 1.0), 0.1, 1.0),
        Material("Platinum", Color(0.672411, 0.637331, 0.585456, 1.0), 0.1, 1.0),
        // Testing materials
        Material("White", Color(1.0, 1.0, 1.0, 1.0), 0.1, 1.0),
        Material("Red", Color(1.0, 0.0, 0.0, 1.0), 0.1, 1.0),
        Material("Blue", Color(0.0, 0.0, 1.0, 1.0), 0.1, 1.0),
        Material("Black", Color(0.0, 1.0, 1.0, 1.0), 0.1, 1.0)
    ]
    
    func loadHDR(_ scene: Scene) {
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        let cubeMap = createCubemap(engine, with: hdr, size: 256, level: 3)
        scene.ambientLight = loadAmbientLight(engine, withHDR: cubeMap)
        
        let skyMaterial = SkyBoxMaterial(engine)
        skyMaterial.textureCubeMap = hdr
        skyMaterial.equirectangular = true
        let skySubpass = SkySubpass()
        skySubpass.material = skyMaterial
        skySubpass.mesh = PrimitiveMesh.createCuboid(engine)
        scene.background.mode = .Sky
        scene.background.sky = skySubpass
    }
    
    func loadPCGSky(_ scene: Scene) {
         let pcgSky = MDLSkyCubeTexture(name: "natrual", channelEncoding: .float16,
                                            textureDimensions: [512, 512], turbidity: 1.0, sunElevation: 1.0,
                                            sunAzimuth: 1.0, upperAtmosphereScattering: 1.0, groundAlbedo: 1.0)
        let cubeMap = try! engine.textureLoader.loadTexture(with: pcgSky)!
        scene.ambientLight = loadAmbientLight(engine, withPCG: cubeMap, lodStart: 2, lodEnd: 5)
        
        let skyMaterial = SkyBoxMaterial(engine)
        skyMaterial.textureCubeMap = cubeMap
        let skySubpass = SkySubpass()
        skySubpass.material = skyMaterial
        skySubpass.mesh = PrimitiveMesh.createCuboid(engine)
        scene.background.mode = .Sky
        scene.background.sky = skySubpass
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        loadHDR(scene)
        scene.postprocessManager.autoExposure = true
        // loadPCGSky(scene)

        let rootEntity = scene.createRootEntity()
        let _: GUI = rootEntity.addComponent()
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(0, 0, -10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let mat = _materials[7]

        let sphere = PrimitiveMesh.createSphere(engine, 0.5, 64)
        for i in 0..<7 {
            for j in 0..<7 {
                let sphereEntity = rootEntity.createChild("SphereEntity\(i)\(j)")
                sphereEntity.transform.position = Vector3(Float(i - 3), Float(j - 3), 0)
                let sphereMtl = PBRMaterial(engine)
                sphereMtl.baseColor = mat.baseColor
                sphereMtl.metallic = simd_clamp(Float(i) / Float(7 - 1), 0, 1.0)
                sphereMtl.roughness = simd_clamp(Float(j) / Float(7 - 1), 0, 1.0)

                let sphereRenderer: MeshRenderer = sphereEntity.addComponent()
                sphereRenderer.mesh = sphere
                sphereRenderer.setMaterial(sphereMtl)
            }
        }
        engine.run()
    }
}

