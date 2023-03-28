//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

class FrameGraph {
    struct Step {
        var render_task: RenderTaskBase
        var realized_resources: [ResourceBase]
        var derealized_resources: [ResourceBase]
    };

    var render_tasks_: [RenderTaskBase] = []
    var resources_: [ResourceBase] = []
    var timeline_: [Step] = []
}
