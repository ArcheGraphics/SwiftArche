//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import Math
import vox_render
import vox_toolkit

private struct Material {
    var name: String = ""
    var baseColor: Color = .init()
    var roughness: Float = 0
    var metallic: Float = 0

    init() {}

    init(_ n: String, _ c: Color, _ r: Float, _ m: Float) {
        name = n
        roughness = r
        metallic = m
        baseColor = c
    }
}

class PbrApp: NSViewController {
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
        Material("Black", Color(0.0, 1.0, 1.0, 1.0), 0.1, 1.0),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)

        engine = Engine(canvas: canvas)

        let scene = Engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(0, 0, 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let materialIndex = 0
        let mat = _materials[materialIndex]

        // init point light
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(3, 3, 3)
        light.transform.lookAt(targetPosition: Vector3(0, 0, 0))
        let directionLight = light.addComponent(DirectLight.self)
        directionLight.intensity = 0.3

        let sphere = PrimitiveMesh.createSphere(radius: 0.5, segments: 30)
        for i in 0 ..< 7 {
            for j in 0 ..< 7 {
                let sphereEntity = rootEntity.createChild("SphereEntity\(i)\(j)")
                sphereEntity.transform.position = Vector3(Float(i - 3), Float(j - 3), 0)
                let sphereMtl = PBRMaterial()
                sphereMtl.baseColor = mat.baseColor
                sphereMtl.metallic = simd_clamp(Float(i) / Float(7 - 1), 0, 1.0)
                sphereMtl.roughness = simd_clamp(Float(j) / Float(7 - 1), 0, 1.0)

                let sphereRenderer = sphereEntity.addComponent(MeshRenderer.self)
                sphereRenderer.mesh = sphere
                sphereRenderer.setMaterial(sphereMtl)
            }
        }

        Engine.run()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}
