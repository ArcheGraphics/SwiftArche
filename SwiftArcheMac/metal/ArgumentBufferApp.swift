//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import Math
import vox_render
import vox_toolkit

private class NewMaterial: Material {
    required init() {
        super.init()
        shader = Shader.create(in: Engine.library("app.shader"), vertexSource: "vertex_argument_quad",
                               fragmentSource: "fragment_argument_quad")

        // can be solved by shader framework
        var argumentDesc = MTLArgumentDescriptor()
        argumentDesc.dataType = .sampler
        argumentDesc.index = 0
        argumentDesc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: "u_baseSampler", descriptor: argumentDesc)

        argumentDesc = MTLArgumentDescriptor()
        argumentDesc.dataType = .texture
        argumentDesc.index = 1
        argumentDesc.access = .readOnly
        argumentDesc.textureType = .type2D
        shaderData.registerArgumentDescriptor(with: "u_baseTexture", descriptor: argumentDesc)

        argumentDesc = MTLArgumentDescriptor()
        argumentDesc.dataType = .float4
        argumentDesc.index = 2
        argumentDesc.access = .readOnly
        argumentDesc.constantBlockAlignment = MemoryLayout<Color>.alignment
        shaderData.registerArgumentDescriptor(with: "u_baseColor", descriptor: argumentDesc)
        shaderData.createArgumentBuffer(with: "u_material")
    }

    var baseColor: Color = .init(1, 0, 0, 1) {
        didSet {
            shaderData.setData(with: "u_baseColor", data: baseColor.toLinear())
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
