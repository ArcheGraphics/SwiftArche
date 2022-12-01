//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class AtomicMaterial: BaseMaterial {
    private var _atomicBuffer: BufferView

    init(_ engine: Engine) {
        _atomicBuffer = BufferView(device: engine.device, count: 1, stride: MemoryLayout<UInt32>.stride)
        super.init(engine.device)
        atomicBuffer = _atomicBuffer
        shader.append(ShaderPass(engine.library("app.shader"), "vertex_atomic", "fragment_atomic"))
    }

    var atomicBuffer: BufferView {
        get {
            _atomicBuffer
        }
        set {
            shaderData.setBufferFunctor("u_atomic") { [self] in
                _atomicBuffer
            }
        }
    }
}

fileprivate class ComputeScript: Script {
    private let _computePass = ComputePass()
    var renderer: MeshRenderer!
    
    override func onAwake() {
        _computePass.shader.append(ShaderPass(engine.library("app.shader"), "compute_atomic"))
        _computePass.threadsPerGridX = 2
        _computePass.threadsPerGridY = 2
        _computePass.threadsPerGridZ = 2
    }

    override func onBeginRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
        if _computePass.data.isEmpty {
            _computePass.data.append(renderer.getMaterial()!.shaderData)
        }
        if let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _computePass.devicePipeline = camera.devicePipeline
            _computePass.compute(commandEncoder: computeCommandEncoder)
            computeCommandEncoder.endEncoding()
        }
    }
}

class AtomicComputeApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)

        engine = Engine(canvas: canvas)
        engine.createShaderLibrary("app.shader")
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 1, y: 1, z: 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
        let counter: ComputeScript = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        let cubeEntity = rootEntity.createChild()
        let renderer: MeshRenderer = cubeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.1)
        let material = AtomicMaterial(engine)
        renderer.setMaterial(material)
        counter.renderer = renderer

        engine.run()
    }
}

