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

class HashGridApp: NSViewController {
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
        var positions: [SIMD3<Float>] = []
        for _ in 0 ..< count {
            positions.append(SIMD3<Float>(Float.random(in: 0 ..< 64), Float.random(in: 0 ..< 64), Float.random(in: 0 ..< 64)))
        }

        let positionBuffer = BufferView(array: positions)
        let itemCount = BufferView(array: [count])
        let hashGrid = HashGrid
            .builder()
            .withGridSpacing(1)
            .withResolution(SIMD3<UInt32>(64, 64, 64))
            .build()
        let scope = Engine.createCaptureScope(name: "hashGrid")
        scope.begin()
        if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
            hashGrid.build(commandBuffer: commandBuffer, positions: positionBuffer,
                           itemCount: itemCount, maxNumberOfParticles: UInt32(count))
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
