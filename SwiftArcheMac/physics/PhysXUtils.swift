//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import ImGui
import Math
import vox_render
import vox_toolkit

func addSphere(_ rootEntity: Entity, _ radius: Float,
               _ position: Vector3, _ rotation: Quaternion, isDynamic: Bool = true) -> Entity
{
    let mtl = PBRMaterial()
    mtl.baseColor = Color(Float.random(in: 0 ... 1), Float.random(in: 0 ... 1), Float.random(in: 0 ... 1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
    let sphereEntity = rootEntity.createChild()
    let renderer = sphereEntity.addComponent(MeshRenderer.self)
    renderer.mesh = PrimitiveMesh.createSphere(radius: radius)
    renderer.setMaterial(mtl)
    sphereEntity.transform.position = position
    sphereEntity.transform.rotationQuaternion = rotation

    let physicsSphere = SphereColliderShape()
    physicsSphere.radius = radius
    if isDynamic {
        let sphereCollider = sphereEntity.addComponent(DynamicCollider.self)
        sphereCollider.addShape(physicsSphere)
    } else {
        let sphereCollider = sphereEntity.addComponent(StaticCollider.self)
        sphereCollider.addShape(physicsSphere)
    }

    return sphereEntity
}

func addCapsule(_ rootEntity: Entity, _ radius: Float, _ height: Float,
                _ position: Vector3, _ rotation: Quaternion, isDynamic: Bool = true) -> Entity
{
    let mtl = PBRMaterial()
    mtl.baseColor = Color(Float.random(in: 0 ... 1), Float.random(in: 0 ... 1), Float.random(in: 0 ... 1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
    let capsuleEntity = rootEntity.createChild()
    let renderer = capsuleEntity.addComponent(MeshRenderer.self)
    renderer.mesh = PrimitiveMesh.createCapsule(radius: radius, height: height, radialSegments: 20)
    renderer.setMaterial(mtl)
    capsuleEntity.transform.position = position
    capsuleEntity.transform.rotationQuaternion = rotation

    let physicsCapsule = CapsuleColliderShape()
    physicsCapsule.radius = radius
    physicsCapsule.height = height
    if isDynamic {
        let capsuleCollider = capsuleEntity.addComponent(DynamicCollider.self)
        capsuleCollider.addShape(physicsCapsule)
    } else {
        let capsuleCollider = capsuleEntity.addComponent(StaticCollider.self)
        capsuleCollider.addShape(physicsCapsule)
    }

    return capsuleEntity
}

func addBox(_ rootEntity: Entity, _ size: Vector3,
            _ position: Vector3, _ rotation: Quaternion, isDynamic: Bool = true) -> Entity
{
    let mtl = PBRMaterial()
    mtl.baseColor = Color(Float.random(in: 0 ... 1), Float.random(in: 0 ... 1), Float.random(in: 0 ... 1), 1.0)
    mtl.metallic = 0.0
    mtl.roughness = 0.5
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

    let physicsBox = BoxColliderShape()
    physicsBox.size = size
    physicsBox.isTrigger = false
    if isDynamic {
        let boxCollider = boxEntity.addComponent(DynamicCollider.self)
        boxCollider.addShape(physicsBox)
        boxCollider.setDensity(1)
    } else {
        let boxCollider = boxEntity.addComponent(StaticCollider.self)
        boxCollider.addShape(physicsBox)
    }

    return boxEntity
}

func addPlane(_ rootEntity: Entity, _ size: Vector3,
              _ position: Vector3, _ rotation: Quaternion) -> Entity
{
    let mtl = PBRMaterial()
    mtl.baseColor = Color(
        0.2179807202597362,
        0.2939682161541871,
        0.31177952549087604,
        1
    )
    mtl.roughness = 0.0
    mtl.metallic = 0.0
    let planeEntity = rootEntity.createChild()
    planeEntity.layer = Layer.Layer1

    let renderer = planeEntity.addComponent(MeshRenderer.self)
    renderer.mesh = PrimitiveMesh.createCuboid(
        width: size.x,
        height: size.y,
        depth: size.z
    )
    renderer.setMaterial(mtl)
    planeEntity.transform.position = position
    planeEntity.transform.rotationQuaternion = rotation

    let physicsPlane = PlaneColliderShape()
    physicsPlane.position = Vector3(0, size.y, 0)
    physicsPlane.isSceneQuery = false
    let planeCollider = planeEntity.addComponent(StaticCollider.self)
    planeCollider.addShape(physicsPlane)

    return planeEntity
}

func addDuckMesh(_ rootEntity: Entity) {
    let assetURL = Bundle.main.url(forResource: "Duck", withExtension: "glb", subdirectory: "glTF-Sample-Models/2.0/Duck/glTF-Binary")!
    GLTFLoader.parse(assetURL, { resource in
        let entity = resource.defaultSceneRoot!
        rootEntity.addChild(entity)

        let colliderShape = MeshColliderShape()
//        colliderShape.isConvex = true
        colliderShape.mesh = resource.meshes![0][0]
        let collider = entity.addComponent(StaticCollider.self)
        collider.addShape(colliderShape)

        rootEntity.getComponent(EngineVisualizer.self)?.addMeshColliderShapeWireframe(with: colliderShape)
    }, true)
}

// MARK: - CollisionScript

class CollisionScript: Script {
    private var sphereRenderer: MeshRenderer!

    override func onAwake() {
        sphereRenderer = entity.getComponent(MeshRenderer.self)
    }

    override func onTriggerEnter(_: ColliderShape) {
//        print("onTriggerEnter")
        if let sphereRenderer {
            (sphereRenderer.getMaterial() as! PBRMaterial).baseColor = Color(Float.random(in: 0 ..< 1),
                                                                             Float.random(in: 0 ..< 1), Float.random(in: 0 ..< 1), 0.5)
        }
    }

    override func onTriggerStay(_: ColliderShape) {
//        print("onTriggerStay")
    }

    override func onTriggerExit(_: ColliderShape) {
//        print("onTriggerExit")
        if let sphereRenderer {
            (sphereRenderer.getMaterial() as! PBRMaterial).baseColor = Color(Float.random(in: 0 ..< 1),
                                                                             Float.random(in: 0 ..< 1), Float.random(in: 0 ..< 1), 0.5)
        }
    }

    override func onCollisionExit(_: Collision) {
//        print("onCollisionExit")
    }

    override func onCollisionStay(_: Collision) {
//        print("onCollisionStay")
    }

    override func onCollisionEnter(_: Collision) {
//        print("onCollisionEnter")
    }
}

// MARK: - PhysicsVisual

@propertyWrapper
struct EnumToBool {
    var number: Bool = false
    var type: VisualizationParameter

    init(type: VisualizationParameter) {
        self.type = type
    }

    var wrappedValue: Bool {
        get { number }
        set {
            if number != newValue {
                number = newValue
                Engine.physicsManager.setVisualType(type, value: newValue)
            }
        }
    }
}

class PhysicsVisual: Script {
    @EnumToBool(type: .WorldAxes)
    var worldAxes: Bool

    @EnumToBool(type: .BodyAxes)
    var bodyAxes: Bool

    @EnumToBool(type: .BodyMassAxes)
    var bodyMassAxes: Bool

    @EnumToBool(type: .BodyLinVelocity)
    var bodyLinVelocity: Bool

    @EnumToBool(type: .BodyAngVelocity)
    var bodyAngVelocity: Bool

    @EnumToBool(type: .ContactPoint)
    var contactPoint: Bool

    @EnumToBool(type: .ContactNormal)
    var contactNormal: Bool

    @EnumToBool(type: .ContactError)
    var contactError: Bool

    @EnumToBool(type: .ContactForce)
    var contactForce: Bool

    @EnumToBool(type: .ActorAxes)
    var actorAxes: Bool

    @EnumToBool(type: .CollisionAABBS)
    var collisionAABBS: Bool

    @EnumToBool(type: .CollisionShapes)
    var collisionShapes: Bool

    @EnumToBool(type: .CollisionAxes)
    var collisionAxes: Bool

    @EnumToBool(type: .CollisionCompounds)
    var collisionCompounds: Bool

    @EnumToBool(type: .CollisionFaceNormal)
    var collisionFaceNormal: Bool

    @EnumToBool(type: .CollisionEdges)
    var collisionEdges: Bool

    @EnumToBool(type: .CollisionStatic)
    var collisionStatic: Bool

    @EnumToBool(type: .CollisionDynamic)
    var collisionDynamic: Bool

    @EnumToBool(type: .JointLocalFrames)
    var jointLocalFrames: Bool

    @EnumToBool(type: .JointLimits)
    var jointLimits: Bool

    @EnumToBool(type: .CullBox)
    var cullBox: Bool

    @EnumToBool(type: .MBPRegins)
    var mbpRegins: Bool

    override func onGUI() {
        UIElement.Init()

        ImGuiNewFrame()
        ImGuiSliderFloat("visual size", &Engine.physicsManager.visualScale, 1.0, 10.0, nil, 1)
        ImGuiCheckbox("worldAxes", &worldAxes)
        ImGuiCheckbox("bodyAxes", &bodyAxes)
        ImGuiCheckbox("bodyMassAxes", &bodyMassAxes)
        ImGuiCheckbox("bodyLinVelocity", &bodyLinVelocity)
        ImGuiCheckbox("bodyAngVelocity", &bodyAngVelocity)

        ImGuiCheckbox("contactPoint", &contactPoint)
        ImGuiCheckbox("contactNormal", &contactNormal)
        ImGuiCheckbox("contactError", &contactError)
        ImGuiCheckbox("contactForce", &contactForce)
        ImGuiCheckbox("actorAxes", &actorAxes)
        ImGuiCheckbox("collisionAABBS", &collisionAABBS)
        ImGuiCheckbox("collisionShapes", &collisionShapes)
        ImGuiCheckbox("collisionAxes", &collisionAxes)
        ImGuiCheckbox("collisionCompounds", &collisionCompounds)
        ImGuiCheckbox("collisionFaceNormal", &collisionFaceNormal)
        ImGuiCheckbox("collisionEdges", &collisionEdges)
        ImGuiCheckbox("collisionStatic", &collisionStatic)
        ImGuiCheckbox("collisionDynamic", &collisionDynamic)
        ImGuiCheckbox("jointLocalFrames", &jointLocalFrames)
        ImGuiCheckbox("jointLimits", &jointLimits)
        ImGuiCheckbox("cullBox", &cullBox)
        ImGuiCheckbox("mbpRegins", &mbpRegins)

        // Rendering
        ImGuiRender()

        Engine.physicsManager.drawGizmos()
    }
}
