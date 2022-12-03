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

class AtomicComputeApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 1, y: 1, z: 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let cubeEntity = rootEntity.createChild()
        let renderer: MeshRenderer = cubeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.1)
        let material = AtomicMaterial(engine)
        renderer.setMaterial(material)
        
        let atomicCounter = ComputePass(engine.device)
        atomicCounter.threadsPerGridX = 2
        atomicCounter.threadsPerGridY = 2
        atomicCounter.threadsPerGridZ = 2
        atomicCounter.shader.append(ShaderPass(engine.library("app.shader"), "compute_atomic"))
        atomicCounter.data.append(renderer.getMaterial()!.shaderData)
        engine.postprocessManager.registerComputePass(atomicCounter)

        engine.run()
    }
}

