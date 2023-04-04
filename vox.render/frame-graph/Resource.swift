//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class ResourceBase {
    private static var idGenerator: Int = 0

    var id_: Int
    var creator_: (() -> FrameTaskBase)?
    var readers_: [() -> FrameTaskBase] = []
    var writers_: [() -> FrameTaskBase] = []
    var ref_count_: Int

    deinit {
        creator_ = nil
        readers_ = []
        writers_ = []
    }

    public var name: String

    public var id: Int {
        id_
    }

    public var transient: Bool {
        creator_ != nil
    }

    public init(name: String, creator: (() -> FrameTaskBase)?) {
        self.name = name
        creator_ = creator
        ref_count_ = 0
        id_ = ResourceBase.idGenerator + 1
        ResourceBase.idGenerator = id_
    }

    open func realize(with _: MTLHeap) -> Bool {
        true
    }

    open func derealize() {}

    open var size: Int {
        0
    }
}

public class Resource<description_type: ResourceRealize>: ResourceBase {
    public typealias actual_type = description_type.actual_type

    var description_: description_type
    var actual_: actual_type?

    deinit {
        actual_ = nil
    }

    public var description: description_type {
        description_
    }

    public var actual: actual_type? {
        actual_
    }

    required init(name: String, creator: @escaping () -> FrameTaskBase, description: description_type) {
        description_ = description
        actual_ = nil
        super.init(name: name, creator: creator)
    }

    required init(name: String, description: description_type, actual: actual_type? = nil) {
        description_ = description
        if let actual {
            actual_ = actual
        } else {
            actual_ = description.realize(with: nil)!
        }
        super.init(name: name, creator: nil)
    }

    override public func realize(with heap: MTLHeap) -> Bool {
        if transient {
            actual_ = description_.realize(with: heap)
            return actual_ != nil
        } else {
            return true
        }
    }

    override public func derealize() {
        if let actual, transient {
            description_.derealize(resource: actual)
            actual_ = nil
        }
    }

    override public var size: Int {
        description_.size
    }
}
