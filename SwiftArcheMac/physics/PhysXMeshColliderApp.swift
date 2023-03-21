//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

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
                mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 0.5)
                mtl.metallic = 0.0
                mtl.roughness = 0.5
                mtl.isTransparent = true
                let meshes = hit.entity!.getComponentsIncludeChildren(MeshRenderer.self)
                for mesh in meshes {
                    mesh.setMaterial(mtl)
                }
            }
        }
    }
}

class PhysXMeshColliderApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    func addCapsuleMesh(_ rootEntity: Entity, _ radius: Float, _ height: Float,
                        _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial()
        mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 0.5)
        mtl.metallic = 0.0
        mtl.roughness = 0.5
        mtl.isTransparent = true
        let capsuleEntity = rootEntity.createChild()
        let renderer = capsuleEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCapsule(radius: radius, height: height,
                                                    radialSegments: 20)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = MeshColliderShape()
        physicsCapsule.isConvex = true
        physicsCapsule.mesh = PrimitiveMesh.createCapsule(radius: radius, height: height,
                                                          radialSegments: 6, heightSegments: 1, noLongerAccessible: false)
        let capsuleCollider = capsuleEntity.addComponent(DynamicCollider.self)
        capsuleCollider.addShape(physicsCapsule)
        
        return capsuleEntity
    }

    func addBoxMesh(_ rootEntity: Entity, _ size: Vector3,
                _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial()
        mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 0.5)
        mtl.metallic = 0.0
        mtl.roughness = 0.5
        mtl.isTransparent = true
        let boxEntity = rootEntity.createChild()
        let renderer = boxEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCuboid(
                width: size.x,
                height: size.y,
                depth: size.z
        )
        renderer.setMaterial(mtl)
        boxEntity.transform.position = position
        boxEntity.transform.rotationQuaternion = rotation

        let physicsBox = MeshColliderShape()
        physicsBox.isConvex = true
        physicsBox.mesh = PrimitiveMesh.createCuboid(
            width: size.x,
            height: size.y,
            depth: size.z, noLongerAccessible: false
        )
        let boxCollider = boxEntity.addComponent(DynamicCollider.self)
        boxCollider.addShape(physicsBox)

        return boxEntity
    }
    
    func initialize(_ rootEntity: Entity) {
        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        for i in 0..<4 {
            for j in 0..<4 {
                let random = Int(floor(Float.random(in: 0...2))) % 2
                switch (random) {
                case 0:
                    _ = addBoxMesh(rootEntity, Vector3(1, 1, 1), Vector3(Float(-4 + i), floor(Float.random(in: 0...6)) + 1, Float(-4 + j)), quat)
                    break
                case 1:
                    _ = addCapsuleMesh(rootEntity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...16)) - 4, 5,
                                                                     floor(Float.random(in: 0...16)) - 4), quat)
                    break
                default:
                    break
                }
            }
        }
        
        addDuckMesh(rootEntity)
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
        rootEntity.addComponent(EngineVisualizer.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(15, 15, 15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera = cameraEntity.addComponent(Camera.self)
        camera.farClipPlane = 1000;
        cameraEntity.addComponent(OrbitControl.self)
        cameraEntity.addComponent(Raycast.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)
        
        initialize(rootEntity)
        
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

