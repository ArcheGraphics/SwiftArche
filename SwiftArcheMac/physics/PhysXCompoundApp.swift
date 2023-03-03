//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class TableGenerator: Script {
    private var _totalTime: Float = 0

    override func onUpdate(_ deltaTime: Float) {
        _totalTime += deltaTime
        if (_totalTime > 0.3) {
            _addTable()
            _totalTime = 0
        }
    }

    private func _addTable() {
        let entity = entity.createChild("entity")
        entity.transform.position = Vector3(
                Float.random(in: -8..<8),
                10,
                Float.random(in: -8..<8)
        )
        entity.transform.rotation = Vector3(
                Float.random(in: 0..<360),
                Float.random(in: 0..<360),
                Float.random(in: 0..<360)
        )
        entity.transform.scale = Vector3(3, 3, 3)
        let boxCollider = entity.addComponent(DynamicCollider.self)
        boxCollider.mass = 10.0

        let boxMaterial = PBRMaterial(engine)
        boxMaterial.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        boxMaterial.metallic = 0
        boxMaterial.roughness = 0.5

        let physicsBox = BoxColliderShape()
        physicsBox.size = Vector3(0.5, 0.4, 0.045)
        physicsBox.position = Vector3(0, 0, 0.125)
        boxCollider.addShape(physicsBox)
        let child = entity.createChild()
        child.transform.position = Vector3(0, 0, 0.125)
        let boxRenderer = child.addComponent(MeshRenderer.self)
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, width: 0.5, height: 0.4, depth: 0.045)
        boxRenderer.setMaterial(boxMaterial)


        let physicsBox1 = BoxColliderShape()
        physicsBox1.size = Vector3(0.1, 0.1, 0.3)
        physicsBox1.position = Vector3(-0.2, -0.15, -0.045)
        boxCollider.addShape(physicsBox1)
        let child1 = entity.createChild()
        child1.transform.position = Vector3(-0.2, -0.15, -0.045)
        let boxRenderer1 = child1.addComponent(MeshRenderer.self)
        boxRenderer1.mesh = PrimitiveMesh.createCuboid(engine, width: 0.1, height: 0.1, depth: 0.3)
        boxRenderer1.setMaterial(boxMaterial)


        let physicsBox2 = BoxColliderShape()
        physicsBox2.size = Vector3(0.1, 0.1, 0.3)
        physicsBox2.position = Vector3(0.2, -0.15, -0.045)
        boxCollider.addShape(physicsBox2)
        let child2 = entity.createChild()
        child2.transform.position = Vector3(0.2, -0.15, -0.045)
        let boxRenderer2 = child2.addComponent(MeshRenderer.self)
        boxRenderer2.mesh = PrimitiveMesh.createCuboid(engine, width: 0.1, height: 0.1, depth: 0.3)
        boxRenderer2.setMaterial(boxMaterial)


        let physicsBox3 = BoxColliderShape()
        physicsBox3.size = Vector3(0.1, 0.1, 0.3)
        physicsBox3.position = Vector3(-0.2, 0.15, -0.045)
        boxCollider.addShape(physicsBox3)
        let child3 = entity.createChild()
        child3.transform.position = Vector3(-0.2, 0.15, -0.045)
        let boxRenderer3 = child3.addComponent(MeshRenderer.self)
        boxRenderer3.mesh = PrimitiveMesh.createCuboid(engine, width: 0.1, height: 0.1, depth: 0.3)
        boxRenderer3.setMaterial(boxMaterial)


        let physicsBox4 = BoxColliderShape()
        physicsBox4.size = Vector3(0.1, 0.1, 0.3)
        physicsBox4.position = Vector3(0.2, 0.15, -0.045)
        boxCollider.addShape(physicsBox4)
        let child4 = entity.createChild()
        child4.transform.position = Vector3(0.2, 0.15, -0.045)
        let boxRenderer4 = child4.addComponent(MeshRenderer.self)
        boxRenderer4.mesh = PrimitiveMesh.createCuboid(engine, width: 0.1, height: 0.1, depth: 0.3)
        boxRenderer4.setMaterial(boxMaterial)

    }
}

class PhysXCompoundApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    func addPlane(_ rootEntity: Entity,
                  _ size: Vector2,
                  _ position: Vector3,
                  _ rotation: Quaternion) -> Entity {
        let engine = rootEntity.engine
        let material = PBRMaterial(engine)
        material.baseColor = Color(0.2179807202597362, 0.2939682161541871, 0.31177952549087604, 1)
        material.roughness = 0.0
        material.metallic = 0.0

        let entity = rootEntity.createChild()
        let renderer = entity.addComponent(MeshRenderer.self)
        entity.transform.position = position
        entity.transform.rotationQuaternion = rotation
        renderer.mesh = PrimitiveMesh.createPlane(engine, width: size.x, height: size.y)
        renderer.setMaterial(material)

        let physicsPlane = PlaneColliderShape()
        let planeCollider = entity.addComponent(StaticCollider.self)
        planeCollider.addShape(physicsPlane)

        return entity
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        scene.shadowDistance = 30
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        
        let rootEntity = scene.createRootEntity()
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(15, 15, 15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-0.3, 1, 0.4)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = .SoftLow

        _ = addPlane(rootEntity, Vector2(30, 30), Vector3(), Quaternion())
        rootEntity.addComponent(TableGenerator.self)

        engine.run()
    }
}

