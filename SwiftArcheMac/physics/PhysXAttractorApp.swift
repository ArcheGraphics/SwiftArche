//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import ImGui

fileprivate class GUI: Script {
    override func onGUI() {
        UIElement.Init(engine)

        ImGuiNewFrame()
        UIElement.frameRate()
        ImGuiRender()
    }
}


fileprivate class Attractor: Script {
    private var collider: DynamicCollider!

    override func onAwake() {
        collider = entity.getComponent(DynamicCollider.self)
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
        camera = entity.getComponent(Camera.self)
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
    var iblBaker: IBLBaker!
    
    func addPlane(_ rootEntity: Entity,
                  _ position: Vector3,
                  _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(0.03179807202597362, 0.3939682161541871, 0.41177952549087604, 1)
        mtl.shader[0].setRenderFace(RenderFace.Double)
        let planeEntity = rootEntity.createChild()
        planeEntity.layer = Layer.Layer1

        // let renderer: MeshRenderer = planeEntity.addComponent()
        // renderer.mesh = PrimitiveMesh.createPlane(rootEntity.engine, 10, 10)
        // renderer.setMaterial(mtl)
        planeEntity.transform.position = position
        planeEntity.transform.rotationQuaternion = rotation

        let physicsPlane = PlaneColliderShape()
        let planeCollider = planeEntity.addComponent(StaticCollider.self)
        planeCollider.addShape(physicsPlane)

        return planeEntity
    }

    func addSphere(_ rootEntity: Entity,
                   _ radius: Float,
                   _ position: Vector3,
                   _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(1.0, 168 / 255, 196 / 255, 1.0)
        mtl.roughness = 0.8;
        mtl.metallic = 0.4;

        let sphereEntity = rootEntity.createChild()
        let renderer = sphereEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createSphere(rootEntity.engine, radius: radius, segments: 60)
        renderer.setMaterial(mtl)
        sphereEntity.transform.position = position
        sphereEntity.transform.rotationQuaternion = rotation

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        let sphereCollider = sphereEntity.addComponent(DynamicCollider.self)
        sphereCollider.addShape(physicsSphere)
        sphereCollider.linearDamping = 0.95
        sphereCollider.angularDamping = 0.2
        sphereEntity.addComponent(Attractor.self)
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
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let rootEntity = scene.createRootEntity()
        rootEntity.addComponent(GUI.self)

        // init camera
        let cameraEntity = rootEntity.createChild("camera")
        let camera = cameraEntity.addComponent(Camera.self)
        cameraEntity.transform.position = Vector3(0, 0, -15)
        cameraEntity.transform.lookAt(targetPosition: Vector3())

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(5, 0, -10)
        light.transform.lookAt(targetPosition: Vector3(0, 0, 0))
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = ShadowType.SoftLow

        let attractorEntity = rootEntity.createChild()
        let interaction = attractorEntity.addComponent(Interaction.self)
        interaction.camera = camera
        // let mtl = PBRMaterial(engine)
        // mtl.baseColor = Color(1, 1, 1, 1.0)
        // let renderer: MeshRenderer = attractorEntity.addComponent()
        // renderer.mesh = PrimitiveMesh.createSphere(engine, 2)
        // renderer.setMaterial(mtl)

        let attractorSphere = SphereColliderShape()
        attractorSphere.radius = 2
        let attractorCollider = attractorEntity.addComponent(DynamicCollider.self)
        attractorCollider.isKinematic = true
        attractorCollider.addShape(attractorSphere)

        engine.physicsManager.gravity = Vector3()
        initialize(rootEntity)

        engine.run()
    }
}

