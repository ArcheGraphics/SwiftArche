//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class RenderTaskBuilder {
    private var framegraph_: FrameGraph
    private var render_task_: RenderTaskBase

    init(framegraph: FrameGraph, render_task: RenderTaskBase) {
        framegraph_ = framegraph
        render_task_ = render_task
    }

    func create<description_type: ResourceRealize>(name: String, description: description_type) -> Resource<description_type> {
        typealias resource_type = Resource<description_type>
        framegraph_.resources_.append(resource_type(name: name, creator: render_task_, description: description));
        let resource = framegraph_.resources_.last!
        render_task_.creates_.append(resource);
        return resource as! resource_type
    }

    func read<resource_type: ResourceBase>(resource: resource_type) -> resource_type {
        resource.readers_.append(render_task_)
        render_task_.reads_.append(resource)
        return resource
    }

    func write<resource_type: ResourceBase>(resource: resource_type) -> resource_type {
        resource.writers_.append(render_task_)
        render_task_.writes_.append(resource)
        return resource
    }
}
