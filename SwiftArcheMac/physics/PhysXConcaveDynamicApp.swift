//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class CupPrefab: Script {
    var convexs: [ConvexHull] = []
    var mesh: ModelMesh!
    var isLoaded: Bool = false
    var height: Float = 3
    var scale: Float = 2
    
    required init(_ entity: Entity) {
        super.init(entity)
        let assetURL = Bundle.main.url(forResource: "cup", withExtension: "glb", subdirectory: "assets")!
        GLTFLoader.parse(entity.engine, assetURL, { [self] resource in
            let entity = resource.defaultSceneRoot!
            mesh = resource.meshes![0][0]
            
            let renderers = entity.getComponentsIncludeChildren(MeshRenderer.self)
            for renderer in renderers {
                for mtl in renderer.getMaterials() {
                    if let mtl = mtl {
                        (mtl as! PBRMaterial).baseColor = Color(1,1,1,0.2)
                        (mtl as! PBRMaterial).isTransparent = true
                    }
                }
            }
            
            let convexCompose = ConvexCompose()
            convexCompose.maxConvexHulls = 20
            convexCompose.resolution = 40_00 // most costly
            convexCompose.compute(for: resource.meshes![0][0])
            convexs = convexCompose.convexHulls
            isLoaded = true
        }, true)
    }
    
    func visualDebug() {
        if isLoaded {
            let collider = entity.addComponent(StaticCollider.self)
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
                let renderer = child.addComponent(MeshRenderer.self)
                renderer.mesh = mesh
                renderer.setMaterial(mtl)
                
                let colliderShape = MeshColliderShape()
                colliderShape.isConvex = true
                colliderShape.cookConvexHull(&convex)
                collider.addShape(colliderShape)
            }
        }
    }
    
    func createPrefab() {
        if isLoaded {
            let child = entity.createChild()
            child.transform.rotation = Vector3(90, 0, 0)
            height += 1
            child.transform.position = Vector3(0, height, 0)
            scale -= 0.25
            child.transform.scale = Vector3(scale, scale, scale)
            
            let mtl = PBRMaterial(engine)
            mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1)
            mtl.roughness = 0.5
            mtl.metallic = 0.5
            let renderer = child.addComponent(MeshRenderer.self)
            renderer.mesh = mesh
            renderer.setMaterial(mtl)
            
            let collider = child.addComponent(DynamicCollider.self)
            for var convex in convexs {
                let colliderShape = MeshColliderShape()
                colliderShape.isConvex = true
                colliderShape.cookConvexHull(&convex)
                collider.addShape(colliderShape)
            }
        }
    }
    
    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        let pointers = inputManager.pointers
        if (!pointers.isEmpty && inputManager.isPointerTrigger(.rightMouseDown)) {
            createPrefab()
//            visualDebug()
        }
    }
}

class PhysXConcaveDynamicApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    fileprivate var prefab: CupPrefab!

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
        prefab = rootEntity.addComponent(CupPrefab.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(10, 10, 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)
        
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
                
        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

