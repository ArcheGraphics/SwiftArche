//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class AtomicMaterial: BaseMaterial {
    private var _atomicBuffer: BufferView

    init(_ engine: Engine) {
        _atomicBuffer = BufferView(device: engine.device, count: 1, stride: MemoryLayout<UInt32>.stride)
        super.init(engine)
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
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(1, 1, 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let cubeEntity = rootEntity.createChild()
        let renderer = cubeEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCuboid(engine, width: 0.1, height: 0.1, depth: 0.1)
        let material = AtomicMaterial(engine)
        renderer.setMaterial(material)

        let atomicCounter = ComputePass(engine)
        atomicCounter.threadsPerGridX = 2
        atomicCounter.threadsPerGridY = 2
        atomicCounter.threadsPerGridZ = 2
        atomicCounter.shader.append(ShaderPass(engine.library("app.shader"), "compute_atomic"))
        atomicCounter.data.append(renderer.getMaterial()!.shaderData)
        scene.postprocessManager.registerComputePass(atomicCounter)

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

