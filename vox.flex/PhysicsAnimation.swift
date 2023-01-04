//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

///
/// Abstract base class for physics-based animation.
///
/// This class represents physics-based animation by adding time-integration
/// specific functions to Animation class.
///
open class PhysicsAnimation: Script {
    var _currentTime: Float = 0.0
    
    public var isUsingFixedSubTimeSteps: Bool = true
    public var numberOfFixedSubTimeSteps: UInt = 1
    
    public var currentTime: Float {
        get {
            _currentTime
        }
    }
    
    public override func onUpdate(_ timeIntervalInSeconds: Float) {
        let scope = engine.createCaptureScope(name: "bitonic")
        scope.begin()
        if let commandBuffer = engine.commandQueue.makeCommandBuffer() {
            commandBuffer.label = "physics animation"
            if isUsingFixedSubTimeSteps {
                logger.info("Using fixed sub-timesteps: \(numberOfFixedSubTimeSteps)")
                
                // Perform fixed time-stepping
                let actualTimeInterval = timeIntervalInSeconds / Float(numberOfFixedSubTimeSteps)
                for _ in 0..<numberOfFixedSubTimeSteps {
                    logger.info("Begin onAdvanceTimeStep: \(actualTimeInterval) (1/\(1.0 / actualTimeInterval)) seconds")
                    onAdvanceTimeStep(commandBuffer, actualTimeInterval)
                }
                _currentTime += actualTimeInterval
            } else {
                logger.info("Using adaptive sub-timesteps")
                
                // Perform adaptive time-stepping
                var remainingTime = timeIntervalInSeconds
                while (remainingTime > Float.leastNonzeroMagnitude) {
                    let numSteps = numberOfSubTimeSteps(remainingTime)
                    let actualTimeInterval = remainingTime / Float(numSteps)
                    
                    logger.info("Number of remaining sub-timesteps: \(numSteps)")
                    logger.info("Begin onAdvanceTimeStep: \(actualTimeInterval) (1/\(1.0 / actualTimeInterval)) seconds")
                    
                    onAdvanceTimeStep(commandBuffer, actualTimeInterval)
                    
                    remainingTime -= actualTimeInterval
                    _currentTime += actualTimeInterval
                }
            }
            commandBuffer.commit()
        }
        scope.end()
    }
    
    open func initialize(_ commandBuffer: MTLCommandBuffer) {}
    
    /// Called when a single time-step should be advanced.
    ///
    /// When Animation::update function is called, this class will internally
    /// subdivide a frame into sub-steps if needed. Each sub-step, or time-step,
    /// is then taken to move forward in time. This function is called for each
    /// time-step, and a subclass that inherits PhysicsAnimation class should
    /// implement this function for its own physics model.
    ///
    /// - Parameter timeIntervalInSeconds: The time interval in seconds
    open func onAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeIntervalInSeconds: Float) {}
    
    /// Returns the required number of sub-timesteps for given time interval.
    ///
    /// The required number of sub-timestep can be different depending on the
    /// physics model behind the implementation. Override this function to
    /// implement own logic for model specific sub-timestepping for given
    /// time interval.
    ///
    /// - Parameter timeIntervalInSeconds: The time interval in seconds.
    /// - Returns: The required number of sub-timesteps.
    open func numberOfSubTimeSteps(_ timeIntervalInSeconds: Float) -> UInt {
        numberOfFixedSubTimeSteps
    }
}
