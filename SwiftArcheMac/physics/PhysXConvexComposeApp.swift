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
//        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        
        let assetURL = Bundle.main.url(forResource: "bunny", withExtension: "glb", subdirectory: "assets")!
        GLTFLoader.parse(rootEntity.engine, assetURL, { [self] resource in
            let entity = resource.defaultSceneRoot!
            rootEntity.addChild(entity)
            
            if let materials = resource.materials {
                for mtl in materials {
                    (mtl as! PBRMaterial).baseColor = Color(1,1,1,0.5)
                    (mtl as! PBRMaterial).isTransparent = true
                }
            }
            
            convexCompose.maxConvexHulls = 10
            convexCompose.resolution = 100_000
            convexCompose.compute(for: resource.meshes![0][0])
            var convexs = convexCompose.convexHulls
            
            // debugger
            for var convex in convexs {
                var indices: [UInt32] = []
                indices.reserveCapacity(convex.triangles.count * 3)
                var position: [Vector3] = []
                position = convex.points.map({ v in
                    Vector3(v)
                })
                convex.triangles.forEach { v in
                    indices.append(v.x)
                    indices.append(v.y)
                    indices.append(v.z)
                }
                let mesh = ModelMesh(engine)
                mesh.setPositions(positions: position)
                mesh.setIndices(indices: indices)
                _ = mesh.addSubMesh(0, indices.count, .triangle)
                mesh.uploadData(true)
                
                let mtl = UnlitMaterial(engine)
                mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1)
                let child = entity.createChild()
                let renderer: MeshRenderer = child.addComponent()
                renderer.mesh = mesh
                renderer.setMaterial(mtl)
                
                let colliderShape = MeshColliderShape()
                colliderShape.isConvex = true
                colliderShape.cookConvexHull(&convex)
                let collider: StaticCollider = entity.addComponent()
                collider.addShape(colliderShape)
                
                createDebugWireframe(colliderShape, entity)
            }
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
        cameraEntity.transform.position = Vector3(2, 2, 2)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
//        let _: Raycast = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()
        
        initialize(rootEntity)

        engine.run()
    }
}

