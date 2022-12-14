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
        sdfMesh.load(with: "assets/bunny.obj")
        sdfMesh.buildBVH()
        sdfMesh.generateSDF(lower: SIMD3<Float>(-1.2, -1.2, -1.2),
                            upper: SIMD3<Float>(1.2, 1.2, 1.2),
                            res: SIMD3<Int>(64, 64, 64))

        engine.run()
    }
}

