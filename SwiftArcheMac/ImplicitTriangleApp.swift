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

class ImplicitTriangleApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        
        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
        
        let sdfMesh = ImplicitTriangleMesh(engine)
        sdfMesh.signRayCount = 12
        let assetURL = Bundle.main.url(forResource: "dragon", withExtension: "obj", subdirectory: "assets")!
        sdfMesh.load(with: assetURL)
        sdfMesh.buildBVH()
        sdfMesh.generateSDF(resolutionX: 100)
        
        let sdfMtl = ImplicitTriangleMaterial(engine)
        sdfMtl.mesh = sdfMesh
        sdfMtl.absThreshold = 0.01
        sdfMtl.maxTraceSteps = 64
        
        let mesh = ModelMesh(engine)
        _ = mesh.addSubMesh(0, 6, .triangleStrip)
        
        let sdfEntity = rootEntity.createChild()
        let sdfRenderer: MeshRenderer = sdfEntity.addComponent()
        sdfRenderer.setMaterial(sdfMtl)
        sdfRenderer.mesh = mesh
        
        engine.run()
    }
}

