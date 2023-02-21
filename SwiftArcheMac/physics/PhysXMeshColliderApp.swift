//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class Raycast: Script {
    var camera: Camera!
    var ray = Ray()

    override func onAwake() {
        camera = entity.getComponent()
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        let pointers = inputManager.pointers
        if (!pointers.isEmpty && inputManager.isPointerTrigger(.leftMouseDown)) {
            _ = camera.screenPointToRay(pointers[0].screenPoint(engine.canvas), ray)

            if let hit = engine.physicsManager.raycast(ray, Float.greatestFiniteMagnitude, Layer.Layer0) {
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

class PhysXMeshColliderApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    func addCapsuleMesh(_ rootEntity: Entity, _ radius: Float, _ height: Float,
                        _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
        mtl.metallic = 0.0
        mtl.roughness = 0.5
        let capsuleEntity = rootEntity.createChild()
        let renderer: MeshRenderer = capsuleEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCapsule(rootEntity.engine, radius: radius, height: height,
                                                    radialSegments: 20)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = MeshColliderShape()
        physicsCapsule.isConvex = true
        physicsCapsule.mesh = PrimitiveMesh.createCapsule(rootEntity.engine, radius: radius, height: height,
                                                          radialSegments: 6, heightSegments: 1, noLongerAccessible: false)
        let capsuleCollider: StaticCollider = capsuleEntity.addComponent()
        capsuleCollider.addShape(physicsCapsule)

        return capsuleEntity
    }

    func addBoxMesh(_ rootEntity: Entity, _ size: Vector3,
                _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
        mtl.metallic = 0.0
        mtl.roughness = 0.5
        let boxEntity = rootEntity.createChild()
        let renderer: MeshRenderer = boxEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(
                rootEntity.engine,
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
            rootEntity.engine,
            width: size.x,
            height: size.y,
            depth: size.z, noLongerAccessible: false
    )
        let boxCollider: DynamicCollider = boxEntity.addComponent()
        boxCollider.addShape(physicsBox)

        return boxEntity
    }
    
    func initialize(_ rootEntity: Entity) {
        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        for i in 0..<8 {
            for j in 0..<8 {
                let random = Int(floor(Float.random(in: 0...3))) % 3
                switch (random) {
                case 0:
                    _ = addBoxMesh(rootEntity, Vector3(1, 1, 1), Vector3(Float(-4 + i), floor(Float.random(in: 0...6)) + 1, Float(-4 + j)), quat)
                    break
//                case 1:
//                    _ = addSphere(rootEntity, 0.5, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4), quat)
//                    break
                case 2:
                    _ = addCapsuleMesh(rootEntity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...16)) - 4, 5,
                                                                     floor(Float.random(in: 0...16)) - 4), quat)
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
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        scene.shadowDistance = 50
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(15, 15, 15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
        let _: Raycast = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight: DirectLight = light.addComponent()
        directLight.shadowType = .SoftLow
        directLight.shadowStrength = 1
        
        initialize(rootEntity)

        engine.run()
    }
}

