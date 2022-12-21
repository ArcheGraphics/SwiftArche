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

class BitonicSortApp: NSViewController {
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
        
        let scope = engine.createCaptureScope(name: "bitonic")
        let bitonicSort = BitonicSort(engine)
        let sortBuffer = BufferView(device: engine.device, array: [
            SIMD2<Float>(0.2, 1),
            SIMD2<Float>(0.5, 2),
            SIMD2<Float>(0.1, 3),
            SIMD2<Float>(0.01, 4),
            SIMD2<Float>(0.3, 5),
            SIMD2<Float>(0.7, 6),
            SIMD2<Float>(0.4, 7),
            SIMD2<Float>(0.24, 8),
            SIMD2<Float>(0, 0),
            SIMD2<Float>(0, 0),
        ])
        let itemCount = BufferView(device: engine.device, array: [UInt(8)])
        scope.begin()
        if let commandBuffer = engine.commandQueue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            bitonicSort.run(commandEncoder: commandEncoder, maxSize: 8, sortBuffer: sortBuffer, itemCount: itemCount)
            commandEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        scope.end()

        engine.run()
    }
}

