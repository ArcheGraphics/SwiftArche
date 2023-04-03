//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class NewMaterial: Material {
    var encoder: MTLArgumentEncoder
    
    init() {
        var argumentDescs: [MTLArgumentDescriptor] = []
        var argumentDesc = MTLArgumentDescriptor()
        argumentDesc.dataType = .sampler
        argumentDesc.index = 0
        argumentDesc.access = .readOnly
        argumentDescs.append(argumentDesc)

        argumentDesc = MTLArgumentDescriptor()
        argumentDesc.dataType = .texture
        argumentDesc.index = 1
        argumentDesc.access = .readOnly
        argumentDesc.textureType = .type2D
        argumentDescs.append(argumentDesc)
        
        argumentDesc = MTLArgumentDescriptor()
        argumentDesc.dataType = .float4
        argumentDesc.index = 2
        argumentDesc.access = .readOnly
        argumentDesc.constantBlockAlignment = MemoryLayout<Color>.alignment
        argumentDescs.append(argumentDesc)
        
        encoder = Engine.device.makeArgumentEncoder(arguments: argumentDescs)!
        var buffer = Engine.device.makeBuffer(length: encoder.encodedLength)!
        encoder.setArgumentBuffer(buffer, offset: 0)
        encoder.constantData(at: 2).copyMemory(from: &baseColor, byteCount: MemoryLayout<Color>.stride)

        super.init(shader: Shader.create(in: Engine.library("app.shader"), vertexSource: "vertex_argument_quad",
                                         fragmentSource: "fragment_argument_quad"))
        shaderData.setData("u_material", BufferView(buffer: buffer, count: 0, stride: 0))
    }
    
    var baseColor: Color = Color(1, 0, 0, 1) {
        didSet {
            encoder.constantData(at: 2).copyMemory(from: &baseColor, byteCount: MemoryLayout<Color>.stride)
        }
    }
}

class ArgumentBufferApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
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

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        let cubeEntity = rootEntity.createChild()
        let renderer = cubeEntity.addComponent(MeshRenderer.self)
        let mesh = Mesh()
        _ = mesh.addSubMesh(0, 6)
        renderer.mesh = mesh
        
        let material = NewMaterial()
        material.baseColor = Color(0.7, 0.0, 0.0)
        renderer.setMaterial(material)

        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

