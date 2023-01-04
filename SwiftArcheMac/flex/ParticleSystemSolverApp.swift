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
    var particleMtl: VolumeParticleEmitterMaterial!
    
    private var highlightIndex: Int32 {
        get {
            Int32(particleMtl.highlightIndex)
        }
        set {
            particleMtl.highlightIndex = UInt32(newValue)
        }
    }

    override func onUpdate(_ deltaTime: Float) {
        UIElement.Init(engine.canvas, deltaTime)

        ImGuiNewFrame()
        ImGuiSliderInt("highlight", &highlightIndex, 0, maxNumber, nil, ImGuiSliderFlags())
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
        let particleMtl = VolumeParticleEmitterMaterial(engine)
        particleMtl.pointRadius = 5
        particleMtl.pointScale = 10
        gui.particleMtl = particleMtl
        gui.maxNumber = Int32(maxNumber)
        
        let particleEntity = rootEntity.createChild()
        let renderer: MeshRenderer = particleEntity.addComponent()
        renderer.mesh = particleMesh
        renderer.setMaterial(particleMtl)
        
        let particleUpdate: ParticleRendererUpdate = rootEntity.addComponent()
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
        let gui: GUI = rootEntity.addComponent()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(1, 1, 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
                
        let emitter = PointParticleEmitter(engine)
        emitter.origin = Vector3F()
        emitter.direction = Vector3F(0, 1, 0)
        emitter.speed = 0.4
        emitter.spreadAngleInDegrees = 45
        emitter.maxNumberOfNewParticlesPerSecond = 300
        
        let particleEntity = rootEntity.createChild()
        let particleSolver: ParticleSystemSolver = particleEntity.addComponent()
        particleSolver.emitter = emitter
        particleSolver.gravity = Vector3F(0, -0.1, 0)
        createParticleRenderer(particleEntity, particleSolver.particleSystemData!, gui)
        
        if let commandBuffer = engine.commandQueue.makeCommandBuffer() {
            particleSolver.initialize(commandBuffer)
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        engine.run()
    }
}

