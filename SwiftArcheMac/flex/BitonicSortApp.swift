//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import Math
import vox_flex
import vox_render
import vox_toolkit

class BitonicSortApp: NSViewController {
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
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)

        let count: UInt = 10000
        var sortArray: [SIMD2<Float>] = []
        for i in 0 ..< count {
            sortArray.append(SIMD2<Float>(Float.random(in: 0 ..< 5), Float(i)))
        }

        let bitonicSort = BitonicSort()
        let sortBuffer = BufferView(array: sortArray)
        let itemCount = BufferView(array: [count])
        let scope = Engine.createCaptureScope(name: "bitonic")
        scope.begin()
        if let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        {
            commandEncoder.label = "bitonic sort"
            bitonicSort.run(commandEncoder: commandEncoder, maxSize: count, sortBuffer: sortBuffer, itemCount: itemCount)
            commandEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        scope.end()

        Engine.run()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}
