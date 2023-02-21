//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class BakerMaterial: BaseMaterial {
    private var _texture: MTLTexture?

    init(_ engine: Engine) {
        super.init(engine)
        let shaderPass = ShaderPass(engine.library("app.shader"), "vertex_cubemap", "fragment_cubemap")
        shaderPass.setRenderFace(.Double)
        shader.append(shaderPass)
    }

    /// Base texture.
    var baseTexture: MTLTexture? {
        get {
            _texture
        }
        set {
            _texture = newValue
            shaderData.setImageView("u_baseTexture", "u_baseSampler", newValue)
        }
    }

    /// Tiling and offset of main textures.
    var faceIndex: Int {
        get {
            1
        }
        set {
            shaderData.setData("u_faceIndex", newValue)

        }
    }
}

class IrradianceApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(0, 0, -10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        // Create Sphere
        let sphereEntity = rootEntity.createChild("box")
        sphereEntity.transform.position = Vector3(-1, 2, 0)
        let sphereMaterial = PBRMaterial(engine)
        sphereMaterial.roughness = 0
        sphereMaterial.metallic = 1
        let renderer: MeshRenderer = sphereEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createSphere(engine, radius: 1, segments: 64)
        renderer.setMaterial(sphereMaterial)

        // Create planes
        var planes: [Entity] = []
        var planeMaterials: [BakerMaterial] = []

        for _ in 0..<6 {
            let bakerEntity = rootEntity.createChild("IBL Baker Entity")
            bakerEntity.transform.rotation = Vector3(90, 0, 0)
            let bakerMaterial = BakerMaterial(engine)
            let bakerRenderer: MeshRenderer = bakerEntity.addComponent()
            bakerRenderer.mesh = PrimitiveMesh.createPlane(engine, width: 2, height: 2)
            bakerRenderer.setMaterial(bakerMaterial)
            planes.append(bakerEntity)
            planeMaterials.append(bakerMaterial)
        }

        planes[0].transform.position = Vector3(1, 0, 0) // PX
        planes[1].transform.position = Vector3(-3, 0, 0) // NX
        planes[2].transform.position = Vector3(1, 2, 0) // PY
        planes[3].transform.position = Vector3(1, -2, 0) // NY
        planes[4].transform.position = Vector3(-1, 0, 0) // PZ
        planes[5].transform.position = Vector3(3, 0, 0) // NZ

        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        let cubeMap = createCubemap(engine, with: hdr, size: 512, level: 3)
        scene.ambientLight.specularTexture = createSpecularTexture(engine, with: cubeMap, format: .rgba16Float)
        let changeMip: (Int) -> Void = {
            (mipLevel: Int) -> Void in
            for i in 0..<6 {
                let material = planeMaterials[i]
                material.baseTexture = cubeMap.makeTextureView(pixelFormat: cubeMap.pixelFormat, textureType: .type2D,
                        levels: mipLevel..<mipLevel + 1, slices: i..<i + 1)
                material.faceIndex = i
            }
        }
        changeMip(0)

        engine.run()
    }
}

