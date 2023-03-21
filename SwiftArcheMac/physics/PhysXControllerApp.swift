//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit
import ImGui

fileprivate class GUI: Script {
    var platformControl: KinematicPlatform!
    private var _platformSpeed: Float = 1
    
    var player: ControlledPlayer!
    
    var platformSpeed: Float {
        get {
            _platformSpeed
        }
        set {
            _platformSpeed = newValue
            platformControl.setDefaultTravelTime(platformSpeed: newValue)
        }
    }
    
    public var jumpGravity: Float = -50.0
    public var jumpForce: Float = 30

    override func onGUI() {
        UIElement.Init()

        ImGuiNewFrame()
        ImGuiSliderFloat("Platform Speed", &platformSpeed, 1.0, 10.0, nil, 1)
        ImGuiSliderFloat("Jump Force", &player.jump.jumpForce, 0.0, 50.0, nil, 1)
        ImGuiSliderFloat("Jump Gravity", &player.jump.jumpGravity, -50, -10.0, nil, 1)
        // Rendering
        ImGuiRender()
    }
}

class PlayerBehavior: ControllerBehavior {
    override init() {
        super.init()
    }

    override func onShapeHit(hit: ControllerColliderHit) {
        if let rigidBody = hit.collider as? DynamicCollider {
            if !rigidBody.isKinematic {
                var dir = hit.entity!.transform.worldPosition - hit.controller!.entity.transform.worldPosition
                dir.y = 0
                rigidBody.applyForceAtPosition(dir.normalized() * 10,
                        hit.controller!.entity.transform.worldPosition,
                                               mode: .Impulse)
            }
        }
    }

    override func getShapeBehaviorFlags(shape: ColliderShape) -> ControllerBehaviorFlag {
        [ControllerBehaviorFlag.CanRideOnObject, ControllerBehaviorFlag.Slide]
    }
}

class PhysXControllerApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    var rootEntity: Entity!
    var cameraEntity: Entity!
    fileprivate var gui: GUI!
    
    @discardableResult
    func addPlayer(_ radius: Float, _ height: Float, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial()
        mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        mtl.roughness = 0.0
        mtl.metallic = 0.0
        let capsuleEntity = rootEntity.createChild()
        let renderer = capsuleEntity.addComponent(MeshRenderer.self)

        renderer.mesh = PrimitiveMesh.createCapsule(radius: radius, height: height, radialSegments: 20)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = CapsuleColliderShape()
        physicsCapsule.radius = radius
        physicsCapsule.height = height

        let characterController = capsuleEntity.addComponent(CharacterController.self)
        characterController.addShape(physicsCapsule)
        characterController.behavior = PlayerBehavior()
        let player = capsuleEntity.addComponent(ControlledPlayer.self)
        player.camera = cameraEntity
        gui.player = player
        
        return capsuleEntity
    }
    
    func initialize(_ rootEntity: Entity) {
        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        for i in 0..<4 {
            for j in 0..<4 {
                let random = Int(floor(Float.random(in: 0...3))) % 3
                switch (random) {
                case 0:
                    _ = addBox(rootEntity, Vector3(3, 3, 3), Vector3(Float(-4 + i), floor(Float.random(in: 0...6)) + 5, Float(-4 + j)),
                               quat, isDynamic: true)
                    break
                case 1:
                    _ = addSphere(rootEntity, 0.5, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4),
                                  quat, isDynamic: true)
                    break
                case 2:
                    _ = addCapsule(rootEntity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4),
                                   quat, isDynamic: true)
                    break
                default:
                    break
                }
            }
        }
        
        let platform = addBox(rootEntity, Vector3(5, 2, 5), Vector3(0, 2, 10), Quaternion(), isDynamic: true)
        let platformControl = platform.addComponent(KinematicPlatform.self)
        platformControl.points = [Vector3(), Vector3(10, 10, 10)]
        platformControl.setDefaultTravelTime(platformSpeed: 1)
        gui.platformControl = platformControl
        
//        addDuckMesh(rootEntity)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker()
        
        let scene = Engine.sceneManager.activeScene!
        let hdr = Engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        
        rootEntity = scene.createRootEntity()
        gui = rootEntity.addComponent(GUI.self)
        
        cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(20, 20, 20)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = ShadowType.SoftLow

        addPlayer(1, 3, Vector3(0, 6.5, 0), Quaternion())

        initialize(rootEntity)
        
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}
