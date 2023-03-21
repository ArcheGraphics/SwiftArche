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

class ImplicitTriangleApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    
    func createSDFRenderer(_ rootEntity: Entity, _ sdf: ImplicitTriangleMesh) {
        let sdfMtl = ImplicitTriangleMaterial()
        sdfMtl.sdf = sdf
        sdfMtl.absThreshold = 0.01
        sdfMtl.maxTraceSteps = 64
        
        let mesh = ModelMesh()
        _ = mesh.addSubMesh(0, 6, .triangleStrip)
        
        let sdfEntity = rootEntity.createChild()
        let sdfRenderer = sdfEntity.addComponent(MeshRenderer.self)
        sdfRenderer.setMaterial(sdfMtl)
        sdfRenderer.mesh = mesh
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        
        let scene = Engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let assetURL = Bundle.main.url(forResource: "dragon", withExtension: "obj", subdirectory: "assets")!
        let triangleMesh = TriangleMesh(device: Engine.device)!
        triangleMesh.load(assetURL)
        
        let sdf = ImplicitTriangleMesh.builder()
            .withTriangleMesh(triangleMesh)
            .withResolutionX(100)
            .build()
        createSDFRenderer(rootEntity, sdf!)
        
        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

