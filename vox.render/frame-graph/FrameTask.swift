//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class FrameTaskBase {
    var creates_: [() -> ResourceBase] = []
    var reads_: [() -> ResourceBase] = []
    var writes_: [() -> ResourceBase] = []
    var events_: [EventWrapper] = []
    var ref_count_: Int

    public var name: String
    public var cull_immune: Bool

    public init(name: String) {
        self.name = name
        cull_immune = false
        ref_count_ = 0
    }

    deinit {
        creates_ = []
        reads_ = []
        writes_ = []
        events_ = []
    }

    open func setup(builder _: inout FrameTaskBuilder) {}

    open func execute() {}
}

public class FrameTask<data_type: EmptyClassType>: FrameTaskBase {
    var data_: data_type
    weak var commandBuffer_: MTLCommandBuffer?
    var setup_: (data_type, inout FrameTaskBuilder) -> Void
    var execute_: (data_type, MTLCommandBuffer?) -> Void

    public var data: data_type {
        data_
    }

    init(name: String, commandBuffer: MTLCommandBuffer?,
         setup: @escaping (data_type, inout FrameTaskBuilder) -> Void,
         execute: @escaping (data_type, MTLCommandBuffer?) -> Void)
    {
        setup_ = setup
        execute_ = execute
        data_ = data_type()
        commandBuffer_ = commandBuffer
        super.init(name: name)
    }

    deinit {
        commandBuffer_ = nil
    }

    override public func setup(builder: inout FrameTaskBuilder) {
        setup_(data_, &builder)
    }

    override public func execute() {
        if let commandBuffer_ {
            // wait for resource ready
            for event in events_ {
                event.wait(for: commandBuffer_)
            }
        }

        execute_(data_, commandBuffer_)

        if let commandBuffer_ {
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
                for nextTask in write().readers_ {
                    nextTask().events_.append(contentsOf: events_)
                }
            }
        }
    }
}
