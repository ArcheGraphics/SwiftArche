//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class RenderTaskBase {
    var creates_: [ResourceBase] = []
    var reads_: [ResourceBase] = []
    var writes_: [ResourceBase] = []
    var events_: [EventWrapper] = []
    var ref_count_: Int

    public var name: String
    public var cull_immune: Bool

    public init(name: String) {
        self.name = name
        self.cull_immune = false
        ref_count_ = 0
    }

    open func setup(builder: inout RenderTaskBuilder) {
    }

    open func execute() {
    }
}

public class RenderTask<data_type: EmptyClassType>: RenderTaskBase {
    var data_: data_type
    var commandBuffer_: MTLCommandBuffer
    var setup_: (data_type, inout RenderTaskBuilder) -> Void
    var execute_: (data_type, MTLCommandBuffer) -> Void

    public var data: data_type {
        data_
    }
    
    init(name: String, commandBuffer: MTLCommandBuffer,
         setup: @escaping (data_type, inout RenderTaskBuilder) -> Void,
         execute: @escaping (data_type, MTLCommandBuffer) -> Void) {
        setup_ = setup
        execute_ = execute
        data_ = data_type()
        commandBuffer_ = commandBuffer
        super.init(name: name)
    }

    public override func setup(builder: inout RenderTaskBuilder) {
        setup_(data_, &builder)
    }

    public override func execute() {
        // wait for resource ready
        for event in events_ {
            event.wait(for: commandBuffer_)
        }
        
        execute_(data_, commandBuffer_)
        
        // signal for resource ready
        for event in events_ {
            event.signal(for: commandBuffer_)
        }
        
        // this pass is the first one
        if events_.isEmpty {
            events_.append(EventWrapper(with: commandBuffer_.device))
        }
        // transport events to next pass
        for write in writes_ {
            for nextTask in write.readers_ {
                nextTask.events_.append(contentsOf: events_)
            }
        }
    }
}
