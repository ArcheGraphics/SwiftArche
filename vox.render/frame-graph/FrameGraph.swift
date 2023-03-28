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
    }

    var render_tasks_: [RenderTaskBase] = []
    var resources_: [ResourceBase] = []
    var timeline_: [Step] = []

    func add_render_task<data_type>(name: String, setup: @escaping (data_type, RenderTaskBuilder) -> Void,
                                    execute: @escaping (data_type) -> Void) -> RenderTask<data_type> {
        render_tasks_.append(RenderTask<data_type>(name: name, setup: setup, execute: execute))
        let render_task = render_tasks_.last!

        let builder = RenderTaskBuilder(framegraph: self, render_task: render_task)
        render_task.setup(builder: builder)

        return render_task as! RenderTask<data_type>
    }

    func add_retained_resource<description_type: ResourceRealize>(name: String, description: description_type,
                                                                  actual: description_type.actual_type? = nil) -> Resource<description_type> {
        resources_.append(Resource<description_type>(name: name, description: description, actual: actual))
        return resources_.last as! Resource<description_type>
    }

    func execute() {
        for step in timeline_ {
            for resource in step.realized_resources {
                resource.realize()
            }
            step.render_task.execute()
            for resource in step.derealized_resources {
                resource.derealize()
            }
        }
    }

    func clear() {
        render_tasks_ = []
        resources_ = []
    }

    func compile() {
        // Reference counting.
        for render_task in render_tasks_ {
            render_task.ref_count_ = render_task.creates_.count + render_task.writes_.count
        }
        for resource in resources_ {
            resource.ref_count_ = resource.readers_.count
        }

        // Culling via flood fill from unreferenced resources.
        var unreferenced_resources: [ResourceBase] = []
        for resource in resources_ {
            if resource.ref_count_ == 0 && resource.transient {
                unreferenced_resources.append(resource)
            }
        }
        while !unreferenced_resources.isEmpty {
            if let unreferenced_resource = unreferenced_resources.popLast() {
                if let creator = unreferenced_resource.creator_ {
                    if (creator.ref_count_ > 0) {
                        creator.ref_count_ -= 1
                    }
                    if (creator.ref_count_ == 0 && !creator.cull_immune) {
                        for read_resource in creator.reads_ {
                            if (read_resource.ref_count_ > 0) {
                                read_resource.ref_count_ -= 1
                            }
                            if (read_resource.ref_count_ == 0 && read_resource.transient) {
                                unreferenced_resources.append(read_resource)
                            }
                        }
                    }
                }

                for writer in unreferenced_resource.writers_ {
                    if (writer.ref_count_ > 0) {
                        writer.ref_count_ -= 1
                    }
                    if (writer.ref_count_ == 0 && !writer.cull_immune) {
                        for read_resource in writer.reads_ {
                            if (read_resource.ref_count_ > 0) {
                                read_resource.ref_count_ -= 1
                            }
                            if (read_resource.ref_count_ == 0 && read_resource.transient) {
                                unreferenced_resources.append(read_resource)
                            }
                        }
                    }
                }
                // end
            }
        }

        // Timeline computation.
        timeline_ = []
        for render_task in render_tasks_ {
            if render_task.ref_count_ == 0 && !render_task.cull_immune {
                continue
            }

            var realized_resources: [ResourceBase] = []
            var derealized_resources: [ResourceBase] = []
            for resource in render_task.creates_ {
                realized_resources.append(resource)
                if (resource.readers_.isEmpty && resource.writers_.isEmpty) {
                    derealized_resources.append(resource)
                }
            }


            var reads_writes = render_task.reads_
            reads_writes.append(contentsOf: render_task.writes_)
            for resource in reads_writes {
                if !resource.transient {
                    continue
                }

                var valid = false
                var last_index: Int = 0
                if !resource.readers_.isEmpty {
                    let index = render_tasks_.firstIndex { iteratee in
                        iteratee === resource.readers_.last
                    }
                    if let index {
                        valid = true
                        last_index = index
                    }
                }
                if resource.writers_.isEmpty {
                    let index = render_tasks_.firstIndex { iteratee in
                        iteratee === resource.writers_.last
                    }
                    if let index {
                        valid = true
                        last_index = max(last_index, index)
                    }
                }
                if (valid && render_tasks_[last_index] === render_task) {
                    derealized_resources.append(resource)
                }
            }
            timeline_.append(Step(render_task: render_task, realized_resources: realized_resources,
                    derealized_resources: derealized_resources))
        }
    }

}
