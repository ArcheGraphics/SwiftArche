//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
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
        UIElement.Init()

        ImGuiNewFrame()
        ImGuiSliderInt("highlight", &highlightIndex, 0, maxNumber, nil, ImGuiSliderFlags())
        // Rendering
        ImGuiRender()
    }
}

class PointEmitterApp: NSViewController {
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
        _ = particleMesh.addSubMesh(0, maxNumber, .point)
        particleMesh._setVertexBufferBinding(0, particleSystem.positions)
        let particleMtl = ParticlePointMaterial()
        particleMtl.pointRadius = 5
        particleMtl.pointScale = 10
        gui.particleMtl = particleMtl
        gui.maxNumber = Int32(maxNumber)
        
        let particleEntity = rootEntity.createChild()
        let renderer = particleEntity.addComponent(MeshRenderer.self)
        renderer.mesh = particleMesh
        renderer.setMaterial(particleMtl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        
        let scene = Engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()
        let gui = rootEntity.addComponent(GUI.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(1, 1, 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let particleSystem = ParticleSystemData(maxLength: 10000)
        
        let emitter = PointParticleEmitter()
        emitter.target = particleSystem
        emitter.origin = Vector3F()
        emitter.direction = Vector3F(0, 1, 0)
        emitter.speed = 1
        emitter.spreadAngleInDegrees = 30
        emitter.maxNumberOfNewParticlesPerSecond = 10
        // todo
        emitter.resourceCache = scene.postprocessManager.postProcessPass.resourceCache!
        if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
            if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                emitter.update(commandEncoder, currentTimeInSeconds: 0, timeIntervalInSeconds: 0.1)
                commandEncoder.endEncoding()
            }
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        
        createParticleRenderer(rootEntity, particleSystem, gui)
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

