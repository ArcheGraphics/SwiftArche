//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class AtmoicScript: Script {
    var atomicCounter: ComputePass!
    private var _atomicBuffer: MTLBuffer

    required init() {
        _atomicBuffer = Engine.device.makeBuffer(length: MemoryLayout<UInt32>.stride)!
        super.init()
    }
    
    final class AtomicEncoderData: EmptyClassType {
        var output: Resource<MTLBufferDescriptor>?
    }
    
    override func onBeginRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
        let fg = Engine.fg
        let atomicResource = fg.addRetainedResource(for: MTLBufferDescriptor.self, name: "atomicBuffer",
                                                    description: MTLBufferDescriptor(count: 1, stride: MemoryLayout<UInt32>.stride),
                                                    actual: _atomicBuffer)
        fg.shaderData.setBufferFunctor("u_atomic") { [self] in
            BufferView(buffer: _atomicBuffer, count: 1, stride: MemoryLayout<UInt32>.stride, offset: 0)
        }
        
        fg.addRenderTask(for: AtomicEncoderData.self, name: "atomic", commandBuffer: commandBuffer) { data, builder in
            data.output = builder.write(resource: atomicResource)
        } execute: { [self] builder, commandBuffer in
            if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                atomicCounter.compute(commandEncoder: commandEncoder)
                commandEncoder.endEncoding()
            }
        }
    }
}

class AtomicComputeApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)

        let scene = Engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(1, 1, 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let cubeEntity = rootEntity.createChild()
        let renderer = cubeEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCuboid(width: 0.1, height: 0.1, depth: 0.1)
        let material = BaseMaterial()
        material.shader.append(ShaderPass(Engine.library("app.shader"), "vertex_atomic", "fragment_atomic"))
        renderer.setMaterial(material)
        
        let atomicCounter = ComputePass(scene)
        atomicCounter.threadsPerGridX = 2
        atomicCounter.threadsPerGridY = 2
        atomicCounter.threadsPerGridZ = 2
        atomicCounter.shader.append(ShaderPass(Engine.library("app.shader"), "compute_atomic"))
        
        let atomicScript = cameraEntity.addComponent(AtmoicScript.self)
        atomicScript.atomicCounter = atomicCounter
        
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

