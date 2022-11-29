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
        if (_totalTime > 300) {
            _addTable()
            _totalTime = 0
        }
    }

    private func _addTable() {
        let entity = entity.createChild("entity")
        entity.transform.setPosition(
                x: Float.random(in: -8..<8),
                y: 10,
                z: Float.random(in: -8..<8)
        )
        entity.transform.setRotation(
                x: Float.random(in: 0..<360),
                y: Float.random(in: 0..<360),
                z: Float.random(in: 0..<360)
        )
        entity.transform.setScale(x: 3, y: 3, z: 3)
        let boxCollider: DynamicCollider = entity.addComponent()
        boxCollider.mass = 10.0

        let boxMaterial = PBRMaterial(engine)
        boxMaterial.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        boxMaterial.metallic = 0
        boxMaterial.roughness = 0.5

        let physicsBox = BoxColliderShape()
        physicsBox.size = Vector3(0.5, 0.4, 0.045)
        _ = physicsBox.position.set(x: 0, y: 0, z: 0.125)
        boxCollider.addShape(physicsBox)
        let child = entity.createChild()
        child.transform.setPosition(x: 0, y: 0, z: 0.125)
        let boxRenderer: MeshRenderer = child.addComponent()
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, 0.5, 0.4, 0.045)
        boxRenderer.setMaterial(boxMaterial)


        let physicsBox1 = BoxColliderShape()
        physicsBox1.size = Vector3(0.1, 0.1, 0.3)
        _ = physicsBox1.position.set(x: -0.2, y: -0.15, z: -0.045)
        boxCollider.addShape(physicsBox1)
        let child1 = entity.createChild()
        child1.transform.setPosition(x: -0.2, y: -0.15, z: -0.045)
        let boxRenderer1: MeshRenderer = child1.addComponent()
        boxRenderer1.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.3)
        boxRenderer1.setMaterial(boxMaterial)


        let physicsBox2 = BoxColliderShape()
        physicsBox2.size = Vector3(0.1, 0.1, 0.3)
        _ = physicsBox2.position.set(x: 0.2, y: -0.15, z: -0.045)
        boxCollider.addShape(physicsBox2)
        let child2 = entity.createChild()
        child2.transform.setPosition(x: 0.2, y: -0.15, z: -0.045)
        let boxRenderer2: MeshRenderer = child2.addComponent()
        boxRenderer2.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.3)
        boxRenderer2.setMaterial(boxMaterial)


        let physicsBox3 = BoxColliderShape()
        physicsBox3.size = Vector3(0.1, 0.1, 0.3)
        _ = physicsBox3.position.set(x: -0.2, y: 0.15, z: -0.045)
        boxCollider.addShape(physicsBox3)
        let child3 = entity.createChild()
        child3.transform.setPosition(x: -0.2, y: 0.15, z: -0.045)
        let boxRenderer3: MeshRenderer = child3.addComponent()
        boxRenderer3.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.3)
        boxRenderer3.setMaterial(boxMaterial)


        let physicsBox4 = BoxColliderShape()
        physicsBox4.size = Vector3(0.1, 0.1, 0.3)
        _ = physicsBox4.position.set(x: 0.2, y: 0.15, z: -0.045)
        boxCollider.addShape(physicsBox4)
        let child4 = entity.createChild()
        child4.transform.setPosition(x: 0.2, y: 0.15, z: -0.045)
        let boxRenderer4: MeshRenderer = child4.addComponent()
        boxRenderer4.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.3)
        boxRenderer4.setMaterial(boxMaterial)

    }
}

class PhysXCompoundApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

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
        let renderer: MeshRenderer = entity.addComponent()
        entity.transform.position = position
        entity.transform.rotationQuaternion = rotation
        renderer.mesh = PrimitiveMesh.createPlane(engine, size.x, size.y)
        renderer.setMaterial(material)

        let physicsPlane = PlaneColliderShape()
        let planeCollider: StaticCollider = entity.addComponent()
        planeCollider.addShape(physicsPlane)

        return entity
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 1, y: 1, z: 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        _ = addPlane(rootEntity, Vector2(30, 30), Vector3(), Quaternion())
        let _: TableGenerator = rootEntity.addComponent()

        engine.run()
    }
}

