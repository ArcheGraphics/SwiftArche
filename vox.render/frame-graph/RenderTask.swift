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
    var ref_count_: Int

    public var name: String
    public var cull_immune: Bool

    public init(name: String) {
        self.name = name
        self.cull_immune = false
        ref_count_ = 0
    }

    open func setup(builder: RenderTaskBuilder) {
    }

    open func execute() {
    }
}

public class RenderTask<data_type>: RenderTaskBase {
    var data_: data_type!
    var setup_: (data_type, RenderTaskBuilder) -> Void
    var execute_: (data_type) -> Void

    public var data: data_type {
        data_
    }
    
    init(name: String, setup: @escaping (data_type, RenderTaskBuilder) -> Void,
         execute: @escaping (data_type) -> Void) {
        setup_ = setup
        execute_ = execute
        super.init(name: name)
    }

    public override func setup(builder: RenderTaskBuilder) {
        setup_(data_, builder)
    }

    public override func execute() {
        execute_(data_)
    }
}
