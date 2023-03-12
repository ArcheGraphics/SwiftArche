//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import vox_flex
import ImGui

fileprivate class GUI: Script {
    var maxNumber: Int32 = 0
    var particleMtl: ParticlePointMaterial!
    
    private var highlightIndex: Int32 {
        get {
            Int32(particleMtl.highlightIndex)
        }
        set {
            particleMtl.highlightIndex = UInt32(newValue)
        }
    }

    override func onGUI() {
        UIElement.Init(engine)

        ImGuiNewFrame()
        ImGuiSliderInt("highlight", &highlightIndex, 0, maxNumber, nil, ImGuiSliderFlags())
        ImGuiSeparator()
        UIElement.frameRate()
        // Rendering
        ImGuiRender()
    }
}

fileprivate class ParticleRendererUpdate: Script {
    var particleSystem: ParticleSystemData!
    var gui: GUI!
    var subMesh: SubMesh!
    
    override func onUpdate(_ deltaTime: Float) {
        let maxNumber: Int = particleSystem.numberOfParticles[0]
        subMesh.count = maxNumber
        gui.maxNumber = Int32(maxNumber)
    }
}

class ParticleSystemSolverApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    
    fileprivate func createParticleRenderer(_ rootEntity: Entity, _ particleSystem: ParticleSystemData, _ gui: GUI) {
        let descriptor = MTLVertexDescriptor()
        let desc = MTLVertexAttributeDescriptor()
        desc.format = .float3
        desc.offset = 0
        desc.bufferIndex = 0
        descriptor.attributes[Int(Position.rawValue)] = desc
        descriptor.layouts[0].stride = 16

        let particleMesh = Mesh()
        particleMesh._vertexDescriptor = descriptor
        let maxNumber: Int = particleSystem.numberOfParticles[0]
        let subMesh = particleMesh.addSubMesh(0, maxNumber, .point)
        particleMesh._setVertexBufferBinding(0, particleSystem.positions)
        let particleMtl = ParticlePointMaterial(engine)
        particleMtl.pointRadius = 5
        particleMtl.pointScale = 10
        gui.particleMtl = particleMtl
        gui.maxNumber = Int32(maxNumber)
        
        let particleEntity = rootEntity.createChild()
        let renderer = particleEntity.addComponent(MeshRenderer.self)
        renderer.mesh = particleMesh
        renderer.setMaterial(particleMtl)
        
        let particleUpdate = rootEntity.addComponent(ParticleRendererUpdate.self)
        particleUpdate.gui = gui
        particleUpdate.particleSystem = particleSystem
        particleUpdate.subMesh = subMesh
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()
        let gui = rootEntity.addComponent(GUI.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(1, 1, 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
                
        let emitter = PointParticleEmitter(engine)
        emitter.origin = Vector3F()
        emitter.direction = Vector3F(0, 1, 0)
        emitter.speed = 0.4
        emitter.spreadAngleInDegrees = 20
        emitter.maxNumberOfNewParticlesPerSecond = 300
        
        let collider = ParticleCapsuleCollider(engine)
        collider.capsuleData.append(CapsuleColliderShapeData(a: Vector3F(1, -1, 0), radius: 0.5, b: Vector3F(-1, -1, 0),
                                                             linearVelocity: Vector3F(), angularVelocity: Vector3F()))
        // raymarching render
        let rayMarchignMaterial = RayMarchingMaterial(engine, "raymarching")
        rayMarchignMaterial.capsuleColliderShapes = collider
        let renderer = rootEntity.addComponent(MeshRenderer.self)
        renderer.setMaterial(rayMarchignMaterial)
        renderer.mesh = PrimitiveMesh.createQuadPlane(engine)
        
        let particleEntity = rootEntity.createChild()
        let particleSolver = particleEntity.addComponent(ParticleSystemSolver.self)
        particleSolver.emitter = emitter
        particleSolver.collider = collider
        particleSolver.gravity = Vector3F(0, -1, 0)
        createParticleRenderer(particleEntity, particleSolver.particleSystemData!, gui)
        
        if let commandBuffer = engine.commandQueue.makeCommandBuffer() {
            particleSolver.initialize(commandBuffer)
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

