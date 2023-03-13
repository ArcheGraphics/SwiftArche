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

class HashGridApp: NSViewController {
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
        cameraEntity.addComponent(Camera.self)
        
        let count: UInt = 10000
        var positions: [SIMD3<Float>] = []
        for _ in 0..<count {
            positions.append(SIMD3<Float>(Float.random(in: 0..<64), Float.random(in: 0..<64), Float.random(in: 0..<64)))
        }
        
        let positionBuffer = BufferView(device: engine.device, array: positions)
        let itemCount = BufferView(device: engine.device, array: [count])
        let hashGrid = HashGrid
            .builder()
            .withGridSpacing(1)
            .withResolution(SIMD3<UInt32>(64, 64, 64))
            .build(engine)
        let scope = engine.createCaptureScope(name: "hashGrid")
        scope.begin()
        if let commandBuffer = engine.commandQueue.makeCommandBuffer() {
            hashGrid.build(commandBuffer: commandBuffer, positions: positionBuffer,
                           itemCount: itemCount, maxNumberOfParticles: UInt32(count))
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        scope.end()

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

