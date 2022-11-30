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

class IBLApp: NSViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)

        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 1, y: 1, z: 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        let materialIndex = 0
        let mat = _materials[materialIndex]
        let cubeMDL = MDLTexture(named: "country")!
        let cubeMap = try! engine.textureLoader.loadTexture(with: "country")!
        scene.ambientLight.specularTexture = engine.textureLoader.createSpecularTexture(with: cubeMap)
        scene.ambientLight.diffuseSphericalHarmonics = engine.textureLoader.createSphericalHarmonicsCoefficients(with: cubeMDL)

        let sphere = PrimitiveMesh.createSphere(engine, 0.5, 64)
        for i in 0..<7 {
            for j in 0..<7 {
                let sphereEntity = rootEntity.createChild("SphereEntity\(i)\(j)")
                sphereEntity.transform.position = Vector3(Float(i - 3), Float(j - 3), 0)
                let sphereMtl = PBRMaterial(engine)
                sphereMtl.baseColor = mat.baseColor
                sphereMtl.metallic = simd_clamp(Float(7 - i) / Float(7 - 1), 0.1, 1.0)
                sphereMtl.roughness = simd_clamp(Float(7 - j) / Float(7 - 1), 0.05, 1.0)

                let sphereRenderer: MeshRenderer = sphereEntity.addComponent()
                sphereRenderer.mesh = sphere
                sphereRenderer.setMaterial(sphereMtl)
            }
        }
        engine.run()
    }
}
