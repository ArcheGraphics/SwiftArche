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

            if let hit = engine.physicsManager.raycast(ray, distance: Float.greatestFiniteMagnitude, layerMask: Layer.Layer0) {
                let mtl = PBRMaterial(engine)
                mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 0.5)
                mtl.metallic = 0.0
                mtl.roughness = 0.5
                mtl.isTransparent = true
                let meshes: [MeshRenderer] = hit.entity!.getComponentsIncludeChildren()
                for mesh in meshes {
                    mesh.setMaterial(mtl)
                }
            }
        }
    }
}

class PhysXConvexComposeApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    var convexCompose: ConvexCompose!
    
    func initialize(_ rootEntity: Entity) {
        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        
        let assetURL = Bundle.main.url(forResource: "Duck", withExtension: "glb", subdirectory: "glTF-Sample-Models/2.0/Duck/glTF-Binary")!
        GLTFLoader.parse(rootEntity.engine, assetURL, { resource in
            let entity = resource.defaultSceneRoot!
            rootEntity.addChild(entity)
            
            self.convexCompose.compute(for: resource.meshes![0][0])
            var convexs = self.convexCompose.convexHulls
            
            let colliderShape = MeshColliderShape()
            colliderShape.isConvex = true
            colliderShape.cookConvexHull(&convexs[0])
            let collider: StaticCollider = entity.addComponent()
            collider.addShape(colliderShape)
            
            createDebugWireframe(colliderShape, entity)
        }, true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        convexCompose = ConvexCompose()
        
        let scene = engine.sceneManager.activeScene!
        scene.shadowDistance = 50
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(15, 15, 15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let camera: Camera = cameraEntity.addComponent()
        camera.farClipPlane = 1000;
        let _: OrbitControl = cameraEntity.addComponent()
        let _: Raycast = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()
        
        initialize(rootEntity)

        engine.run()
    }
}

