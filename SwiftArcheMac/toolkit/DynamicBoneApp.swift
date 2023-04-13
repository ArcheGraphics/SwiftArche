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

private class GUI: Script {
    private var _dynamicBone: DynamicBone!
    var collider: DynamicBoneCollider!

    override func onAwake() {
        let colliderEntity = entity.createChild()
        colliderEntity.transform.position = Vector3(3, -2)
        collider = colliderEntity.addComponent(DynamicBoneCollider.self)
    }

    var dynamicBone: DynamicBone {
        get {
            _dynamicBone
        }
        set {
            _dynamicBone = newValue
            _dynamicBone.m_Colliders.append(collider)
        }
    }

    override func onGUI() {
        UIElement.Init()

        Gizmos.addSphere(sphereCenter: collider.entity.transform.position, sphereRadius: collider.m_Radius,
                         color: Color32(r: 255, g: 255, b: 255), renderFlags: .Wireframe)

        ImGuiNewFrame()
        ImGuiSliderFloat("elasticity", &dynamicBone.m_Elasticity, 0, 1.0, nil, 1)
        ImGuiSliderFloat("damping", &dynamicBone.m_Damping, 0, 1.0, nil, 1)
        ImGuiSliderFloat("friction", &dynamicBone.m_Friction, 0, 1.0, nil, 1)
        ImGuiSliderFloat("stiffness", &dynamicBone.m_Stiffness, 0, 1.0, nil, 1)
        ImGuiSliderFloat("inert", &dynamicBone.m_Inert, 0, 1.0, nil, 1)
        ImGuiSliderFloat("gravityY", &dynamicBone.m_Gravity.y, -10, 10.0, nil, 1)
        ImGuiSliderFloat("radius", &dynamicBone.m_Radius, 0.0, 10.0, nil, 1)
        ImGuiSliderFloat("collider radius", &collider.m_Radius, 0.0, 10.0, nil, 1)
        ImGuiSliderFloat("collider Y", &collider.entity.transform.position.y, -10.0, 10.0, nil, 1)
        ImGuiSliderFloat("blend weight", &dynamicBone.m_BlendWeight, 0.0, 1.0, nil, 1)
        // Rendering
        ImGuiRender()
    }
}

private class MoveScript: Script {
    private var _rTri: Float = 0

    override func onUpdate(_ deltaTime: Float) {
        _rTri += deltaTime * 8
        entity.transform.position = Vector3(0, cos(_rTri), 0)
    }
}

class DynamicBoneApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    func createEntity(_ entity: Entity, offset: Vector3,
                      color: Color = Color(0.7, 0.0, 0.0)) -> Entity
    {
        let cubeEntity = entity.createChild()
        cubeEntity.transform.position = offset
        let renderer = cubeEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCuboid()
        let material = PBRMaterial()
        material.baseColor = color
        renderer.setMaterial(material)
        return cubeEntity
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
        let rootEntity = scene.createRootEntity()
        let gui = rootEntity.addComponent(GUI.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(10, 10, 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        let control = cameraEntity.addComponent(OrbitControl.self)
        control.target = Vector3(4, -4)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        var entity = createEntity(rootEntity, offset: Vector3(1, -1), color: Color(0, 0.7, 0))
        entity.addComponent(MoveScript.self)
        let dynamicBone = entity.addComponent(DynamicBone.self)
        gui.dynamicBone = dynamicBone
        dynamicBone.setWeight(w: 0.9)

        entity = createEntity(entity, offset: Vector3(1, -1, 0))
        dynamicBone.m_Root = entity.transform

        entity = createEntity(entity, offset: Vector3(1, -1, 0))
        entity = createEntity(entity, offset: Vector3(1, -1, 0))
        entity = createEntity(entity, offset: Vector3(1, -1, 0))
        entity = createEntity(entity, offset: Vector3(1, -1, 0))
        entity = createEntity(entity, offset: Vector3(1, -1, 0))
        entity = createEntity(entity, offset: Vector3(1, -1, 0))

        Engine.run()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}
