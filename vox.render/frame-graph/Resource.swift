//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class ResourceBase {
    private static var idGenerator: Int = 0

    var id_: Int
    var creator_: RenderTaskBase?
    var readers_: [RenderTaskBase] = []
    var writers_: [RenderTaskBase] = []
    var ref_count_: Int

    public var name: String

    public var id: Int {
        id_
    }

    public var transient: Bool {
        creator_ != nil
    }

    public init(name: String, creator: RenderTaskBase?) {
        self.name = name
        creator_ = creator
        ref_count_ = 0
        id_ = ResourceBase.idGenerator + 1
        ResourceBase.idGenerator = id_
    }

    open func realize() {
    }

    open func derealize() {
    }
}

class Resource<description_type: ResourceRealize>: ResourceBase {
    typealias actual_type = description_type.actual_type

    var description_: description_type
    var actual_: actual_type?

    var description: description_type {
        description_
    }

    var actual: actual_type? {
        actual_
    }

    required init(name: String, creator: RenderTaskBase, description: description_type) {
        description_ = description
        actual_ = nil
        super.init(name: name, creator: creator)
    }

    required init(name: String, description: description_type, actual: actual_type? = nil) {
        description_ = description
        if let actual {
            actual_ = actual
        } else {
            actual_ = description.realize()!
        }
        super.init(name: name, creator: nil)
    }

    override func realize() {
        if transient {
            actual_ = description_.realize()
        }
    }

    override func derealize() {
        if transient {
            actual_ = nil
        }
    }
}
