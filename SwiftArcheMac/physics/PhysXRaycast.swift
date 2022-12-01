//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class GeometryGenerator: Script {
    var quat: Quaternion = Quaternion(0, 0, 0.3, 0.7)

    override func onAwake() {
        _ = quat.normalize()
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        if (inputManager.isPointerTrigger(.leftMouseDown)) {
            if (Float.random(in: 0...1) > 0.5) {
                _ = addSphere(entity, 0.5, Vector3(floor(Float.random(in: 0...6)) - 2.5, 5, floor(Float.random(in: 0...6)) - 2.5), quat)
            } else {
                _ = addCapsule(entity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...6)) - 2.5, 5, floor(Float.random(in: 0...6)) - 2.5), quat)
            }
        }
    }
}

fileprivate class Raycast: Script {
    var camera: Camera!
    var ray = Ray()
    var hit = HitResult()

    override func onAwake() {
        camera = entity.getComponent()
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        let pointers = inputManager.pointers
        if (!pointers.isEmpty && inputManager.isPointerTrigger(.leftMouseDown)) {
            let pointerPosition = pointers[0].locationInWindow
            _ = camera.screenPointToRay(Vector2(Float(pointerPosition.x), Float(pointerPosition.y)), ray)

            let result = engine.physicsManager.raycast(ray, Float.greatestFiniteMagnitude, Layer.Layer0, hit)
            if (result) {
                let mtl = PBRMaterial(engine)
                mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
                mtl.metallic = 0.0
                mtl.roughness = 0.5

                let meshes: [MeshRenderer] = hit.entity!.getComponentsIncludeChildren()
                for mesh in meshes {
                    mesh.setMaterial(mtl)
                }
            }
        }
    }
}

class PhysXRaycastApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    func initialize(_ rootEntity: Entity) {
        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        for i in 0..<8 {
            for j in 0..<8 {
                let random = Int(floor(Float.random(in: 0...3))) % 3
                switch (random) {
                case 0:
                    _ = addBox(rootEntity, Vector3(1, 1, 1), Vector3(Float(-4 + i), floor(Float.random(in: 0...6)) + 1, Float(-4 + j)), quat)
                    break
                case 1:
                    _ = addSphere(rootEntity, 0.5, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4), quat)
                    break
                case 2:
                    _ = addCapsule(rootEntity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4), quat)
                    break
                default:
                    break
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        engine.createShaderLibrary("app.shader")

        let scene = engine.sceneManager.activeScene!
        scene.ambientLight = loadAmbientLight(engine, with: "countryIBL")
        let rootEntity = scene.createRootEntity()
        let _: GeometryGenerator = rootEntity.addComponent()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 10, y: 10, z: 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 1, y: 3, z: 0)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()

        initialize(rootEntity)

        engine.run()
    }
}

