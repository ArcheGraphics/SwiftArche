//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class FrameGraph {
    struct Step {
        var render_task: FrameTaskBase
        var realized_resources: [ResourceBase]
        var derealized_resources: [ResourceBase]
    }

    var render_tasks_: [FrameTaskBase] = []
    var resources_: [ResourceBase] = []
    private var timeline_: [Step] = []
    private var heapPool_: [MTLHeap] = []

    public var blackboard: [Int: ResourceBase] = [:]

    public var frameData = FrameData()

    public init(size: Int) {
        let heapDesc = MTLHeapDescriptor()
        heapDesc.storageMode = .private
        heapDesc.size = size
        heapPool_.append(Engine.device.makeHeap(descriptor: heapDesc)!)
    }

    @discardableResult
    public func addFrameTask<data_type: EmptyClassType>(for _: data_type.Type, name: String,
                                                        commandBuffer: MTLCommandBuffer?,
                                                        setup: @escaping (data_type, inout FrameTaskBuilder) -> Void,
                                                        execute: @escaping (data_type, MTLCommandBuffer?) -> Void) -> FrameTask<data_type>
    {
        render_tasks_.append(FrameTask<data_type>(name: name, commandBuffer: commandBuffer,
                                                  setup: setup, execute: execute))
        let render_task = render_tasks_.last!

        var builder = FrameTaskBuilder(framegraph: self, render_task: render_task)
        render_task.setup(builder: &builder)

        return render_task as! FrameTask<data_type>
    }

    public func addMoveTask<src_type: ResourceRealize, dst_type: ResourceRealize>(src: Resource<src_type>, dst: Resource<dst_type>) {
        dst.readers_ = src.readers_
        src.readers_ = []
    }

    @discardableResult
    public func addRetainedResource<description_type: ResourceRealize>(for _: description_type.Type, name: String,
                                                                       description: description_type,
                                                                       actual: description_type.actual_type? = nil)
        -> Resource<description_type>
    {
        resources_.append(Resource<description_type>(name: name, description: description, actual: actual))
        return resources_.last as! Resource<description_type>
    }

    public func execute() {
        for step in timeline_ {
            for resource in step.realized_resources {
                var realized = false
                for heap in heapPool_ {
                    if resource.realize(with: heap) {
                        realized = true
                        break
                    }
                }

                // if not big enough locate create new one
                if !realized {
                    let heapDesc = MTLHeapDescriptor()
                    heapDesc.storageMode = .private
                    heapDesc.size = resource.size * 2
                    let heap = Engine.device.makeHeap(descriptor: heapDesc)!
                    heapPool_.append(heap)
                    let result = resource.realize(with: heap)
                    assert(result == true)
                }
            }
            step.render_task.execute()
            for resource in step.derealized_resources {
                resource.derealize()
            }
        }
    }

    public func clear() {
        render_tasks_ = []
        resources_ = []
        blackboard = [:]
        frameData.clear()
        _mergeHeap()
    }

    public func compile() {
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
            if resource.ref_count_ == 0, resource.transient {
                unreferenced_resources.append(resource)
            }
        }
        while !unreferenced_resources.isEmpty {
            if let unreferenced_resource = unreferenced_resources.popLast() {
                if let creator_functor = unreferenced_resource.creator_ {
                    let creator = creator_functor()
                    if creator.ref_count_ > 0 {
                        creator.ref_count_ -= 1
                    }
                    if creator.ref_count_ == 0, !creator.cull_immune {
                        for read_resource_functor in creator.reads_ {
                            let read_resource = read_resource_functor()
                            if read_resource.ref_count_ > 0 {
                                read_resource.ref_count_ -= 1
                            }
                            if read_resource.ref_count_ == 0, read_resource.transient {
                                unreferenced_resources.append(read_resource)
                            }
                        }
                    }
                }

                for writer_functor in unreferenced_resource.writers_ {
                    let writer = writer_functor()
                    if writer.ref_count_ > 0 {
                        writer.ref_count_ -= 1
                    }
                    if writer.ref_count_ == 0, !writer.cull_immune {
                        for read_resource_functor in writer.reads_ {
                            let read_resource = read_resource_functor()
                            if read_resource.ref_count_ > 0 {
                                read_resource.ref_count_ -= 1
                            }
                            if read_resource.ref_count_ == 0, read_resource.transient {
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
            if render_task.ref_count_ == 0, !render_task.cull_immune {
                continue
            }

            var realized_resources: [ResourceBase] = []
            var derealized_resources: [ResourceBase] = []
            for resource_functor in render_task.creates_ {
                let resource = resource_functor()
                realized_resources.append(resource)
                if resource.readers_.isEmpty, resource.writers_.isEmpty {
                    derealized_resources.append(resource)
                }
            }

            var reads_writes = render_task.reads_
            reads_writes.append(contentsOf: render_task.writes_)
            for resource_functor in reads_writes {
                let resource = resource_functor()
                if !resource.transient {
                    continue
                }

                var valid = false
                var last_index = 0
                if !resource.readers_.isEmpty {
                    let index = render_tasks_.firstIndex { iteratee in
                        if let last = resource.readers_.last {
                            return iteratee === last()
                        } else {
                            return false
                        }
                    }
                    if let index {
                        valid = true
                        last_index = index
                    }
                }
                if resource.writers_.isEmpty {
                    let index = render_tasks_.firstIndex { iteratee in
                        if let last = resource.writers_.last {
                            return iteratee === last()
                        } else {
                            return false
                        }
                    }
                    if let index {
                        valid = true
                        last_index = max(last_index, index)
                    }
                }
                if valid, render_tasks_[last_index] === render_task {
                    derealized_resources.append(resource)
                }
            }
            timeline_.append(Step(render_task: render_task, realized_resources: realized_resources,
                                  derealized_resources: derealized_resources))
        }
    }

    @discardableResult
    public func exportGraphviz(filename: String) -> Bool {
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil, create: true)
        let fileURL = dir?.appendingPathComponent(filename).appendingPathExtension("dot")

        var text = ""
        _exportGraphviz(stream: &text)

        do {
            try text.write(to: fileURL!, atomically: false, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    private func _exportGraphviz(stream: inout String) {
        stream += "digraph framegraph \n{\n"

        stream += "rankdir = LR\n"
        stream += "bgcolor = black\n\n"
        stream += "node [shape=rectangle, fontname=\"helvetica\", fontsize=12]\n\n"

        for render_task in render_tasks_ {
            stream += "\""
            stream += render_task.name
            stream += "\" [label=\""
            stream += render_task.name
            stream += "\\nRefs: "
            stream += String(render_task.ref_count_)
            stream += "\", style=filled, fillcolor=darkorange]\n"
        }
        stream += "\n"

        for resource in resources_ {
            stream += "\""
            stream += resource.name
            stream += "\" [label=\""
            stream += resource.name
            stream += "\\nRefs: "
            stream += String(resource.ref_count_)
            stream += "\\nID: "
            stream += String(resource.id)
            stream += "\", style=filled, fillcolor= "
            stream += resource.transient ? "skyblue" : "steelblue"
            stream += "]\n"
        }
        stream += "\n"

        for render_task in render_tasks_ {
            stream += "\""
            stream += render_task.name
            stream += "\" -> { "
            for resource in render_task.creates_ {
                stream += "\""
                stream += resource().name
                stream += "\" "
            }
            stream += "} [color=seagreen]\n"

            stream += "\""
            stream += render_task.name
            stream += "\" -> { "
            for resource in render_task.writes_ {
                stream += "\""
                stream += resource().name
                stream += "\" "
            }
            stream += "} [color=gold]\n"
        }
        stream += "\n"

        for resource in resources_ {
            stream += "\""
            stream += resource.name
            stream += "\" -> { "
            for render_task in resource.readers_ {
                stream += "\""
                stream += render_task().name
                stream += "\" "
            }
            stream += "} [color=firebrick]\n"
        }
        stream += "}"
    }

    // TODO: Optimize for less memory fragment
    private func _mergeHeap() {
        if heapPool_.count > 1 {
            var totalSize: Int = 0
            for heap in heapPool_ {
                totalSize += heap.size
            }

            let heapDesc = MTLHeapDescriptor()
            heapDesc.storageMode = .private
            heapDesc.size = totalSize * 2
            heapPool_ = [Engine.device.makeHeap(descriptor: heapDesc)!]
        }
    }
}
