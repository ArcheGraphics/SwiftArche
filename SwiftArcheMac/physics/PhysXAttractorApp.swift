//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class Attractor: Script {
    private var collider: DynamicCollider!

    override func onAwake() {
        collider = entity.getComponent()
    }

    override func onPhysicsUpdate() {
        var force = entity.transform.worldPosition
        _ = force.normalize()
        force *= -10
        collider.applyForce(force)
    }
}

fileprivate class Interaction: Script {
    var ray = Ray()
    var position = Vector3()
    var rotation = Quaternion()
    var camera: Camera!

    override func onAwake() {
        camera = entity.getComponent()
    }

    override func onUpdate(_ deltaTime: Float) {
        let pointers = engine.inputManager.pointers
        if (pointers.count > 0) {
            _ = camera.screenPointToRay(pointers[0].screenPoint(engine.canvas), ray)
            entity.transform.position = ray.origin + ray.direction * 18
        }
    }
}


class PhysXAttractorApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    func addPlane(_ rootEntity: Entity,
                  _ position: Vector3,
                  _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(0.03179807202597362, 0.3939682161541871, 0.41177952549087604, 1)
        mtl.shader[0].setRenderFace(RenderFace.Double)
        let planeEntity = rootEntity.createChild()
        planeEntity.layer = Layer.Layer1

        let renderer: MeshRenderer = planeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createPlane(rootEntity.engine, 10, 10)
        // renderer.setMaterial(mtl)
        planeEntity.transform.position = position
        planeEntity.transform.rotationQuaternion = rotation

        let physicsPlane = PlaneColliderShape()
        let planeCollider: StaticCollider = planeEntity.addComponent()
        planeCollider.addShape(physicsPlane)

        return planeEntity
    }

    func addSphere(_ rootEntity: Entity,
                   _ radius: Float,
                   _ position: Vector3,
                   _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(1.0, 168 / 255, 196 / 255, 1.0)
        mtl.roughness = 1
        mtl.metallic = 0

        let sphereEntity = rootEntity.createChild()
        let renderer: MeshRenderer = sphereEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createSphere(rootEntity.engine, radius, 60)
        renderer.setMaterial(mtl)
        sphereEntity.transform.position = position
        sphereEntity.transform.rotationQuaternion = rotation

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        let sphereCollider: DynamicCollider = sphereEntity.addComponent()
        sphereCollider.addShape(physicsSphere)
        sphereCollider.linearDamping = 0.95
        sphereCollider.angularDamping = 0.2
        let _: Attractor = sphereEntity.addComponent()
        return sphereEntity
    }

    func initialize(_ rootEntity: Entity) {
        _ = addPlane(rootEntity, Vector3(0, -8, 0), Quaternion())
        var quat180 = Quaternion()
        _ = quat180.rotateZ(rad: MathUtil.degreeToRadian(180))
        _ = addPlane(rootEntity, Vector3(0, 8, 0), quat180)

        var quat90 = Quaternion()
        _ = quat90.rotateZ(rad: MathUtil.degreeToRadian(90))
        _ = addPlane(rootEntity, Vector3(10, 0, 0), quat90)

        var quatNega90 = Quaternion()
        _ = quatNega90.rotateZ(rad: MathUtil.degreeToRadian(-90))
        _ = addPlane(rootEntity, Vector3(-10, 0, 0), quatNega90)

        var quatFront90 = Quaternion()
        _ = quatFront90.rotateX(rad: MathUtil.degreeToRadian(-90))
        _ = addPlane(rootEntity, Vector3(0, 0, 10), quatFront90)

        var quatNegaFront90 = Quaternion()
        _ = quatNegaFront90.rotateX(rad: MathUtil.degreeToRadian(90))
        _ = addPlane(rootEntity, Vector3(0, 0, 0), quatNegaFront90)

        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        for i in 0..<4 {
            for j in 0..<4 {
                for k in 0..<4 {
                    _ = addSphere(rootEntity, 1, Vector3(Float(-4 + 2 * i), Float(-4 + 2 * j), Float(-4 + 2 * k)), quat)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        
        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        let cubeMap = createCubemap(engine, with: hdr, size: 256, level: 3)
        scene.ambientLight = loadAmbientLight(engine, withHDR: cubeMap)
        let rootEntity = scene.createRootEntity()

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let camera: Camera = cameraEntity.addComponent()
        cameraEntity.transform.position = Vector3(0, 0, -15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 5, y: 0, z: -10)
        light.transform.lookAt(targetPosition: Vector3(0, 0, 0))
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()
//        p.shadowType = ShadowType.SoftLow

        let attractorEntity = rootEntity.createChild()
        let interaction: Interaction = attractorEntity.addComponent()
        interaction.camera = camera
        let mtl = PBRMaterial(engine)
        _ = mtl.baseColor.set(r: 1, g: 1, b: 1, a: 1.0)
        let renderer: MeshRenderer = attractorEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createSphere(engine, 2)
        // renderer.setMaterial(mtl)

        let attractorSphere = SphereColliderShape()
        attractorSphere.radius = 2
        let attractorCollider: DynamicCollider = attractorEntity.addComponent()
        attractorCollider.isKinematic = true
        attractorCollider.addShape(attractorSphere)

        engine.physicsManager.gravity = Vector3()
        initialize(rootEntity)

        engine.run()
    }
}

