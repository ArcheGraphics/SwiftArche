//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class GeometryGenerator: Script {
    var quat: Quaternion = Quaternion(x: 0, y: 0, z: 0.3, w: 0.7).normalized

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = Engine.inputManager
        if (inputManager.isPointerTrigger(.rightMouseDown)) {
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

    override func onAwake() {
        camera = entity.getComponent(Camera.self)
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = Engine.inputManager
        let pointers = inputManager.pointers
        if (!pointers.isEmpty && inputManager.isPointerTrigger(.leftMouseDown)) {
            _ = camera.screenPointToRay(pointers[0].screenPoint(Engine.canvas), ray)

            if let hit = Engine.physicsManager.raycast(ray, distance: Float.greatestFiniteMagnitude, layerMask: Layer.Layer0) {
                let mtl = PBRMaterial()
                mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
                mtl.metallic = 0.0
                mtl.roughness = 0.5

                let meshes = hit.entity!.getComponentsIncludeChildren(MeshRenderer.self)
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
    var iblBaker: IBLBaker!
    
    func initialize(_ rootEntity: Entity) {
        let quat = Quaternion(x: 0, y: 0, z: 0.3, w: 0.7).normalized
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
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker()
        
        let scene = Engine.sceneManager.activeScene!
        scene.shadowDistance = 50
        let hdr = Engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let rootEntity = scene.createRootEntity()
        rootEntity.addComponent(GeometryGenerator.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(15, 15, 15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        cameraEntity.addComponent(Raycast.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = .SoftLow
        directLight.shadowStrength = 1
        
        initialize(rootEntity)

        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

