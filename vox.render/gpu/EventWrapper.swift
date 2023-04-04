//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Event wrapper protocol and class providing basic synchronization routines to facilitate encoders ordering.
/// On signaling it advances the internal counter for integrity.
public class EventWrapper {
    /// Event, controlling sequential operations on GPU
    private let _event: MTLEvent
    /// filters calls counter
    private var _signalCounter: UInt64

    public init(with device: MTLDevice) {
        // create event
        _event = device.makeEvent()!
        // zero out signal counter
        _signalCounter = 0
    }

    /// wait for an event
    public func wait(for commandBuffer: MTLCommandBuffer) {
        assert(commandBuffer.device === _event.device)
        // Wait for the event to be signaled
        commandBuffer.encodeWaitForEvent(_event, value: _signalCounter)
    }

    /// signal an event
    public func signal(for commandBuffer: MTLCommandBuffer) {
        assert(commandBuffer.device === _event.device)
        // Increase the signal counter
        _signalCounter += 1
        // Signal the event
        commandBuffer.encodeSignalEvent(_event, value: _signalCounter)
    }
}
