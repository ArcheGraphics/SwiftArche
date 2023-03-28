//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
import vox_render

final class FrameGraphTests: XCTestCase {
    func testExample() throws {
        let frameGraph = FrameGraph()
        let render_task_0: RenderTask<render_task_0_data> =
        frameGraph.addRenderTask(name: "Render Task 0") { data, builder in
            data.output = builder.write(resource: builder.read(resource: builder.create(name: "Resource 0",
                                                                                        description: texture_description(name: "0"))));
        } execute: { data in
            if let actual1 = data.output.actual {
                print(actual1)
            }
        }
        let data_0 = render_task_0.data
        for i in 1...4 {
            let _: RenderTask<render_task_data> =
            frameGraph.addRenderTask(name: "Render Task \(i)") { data, builder in
                data.input = builder.read(resource: data_0.output);
                data.output = builder.write(resource: builder.create(name: "Resource \(i)", description: texture_description(name: String(i))))
            } execute: { data in
               if let actual1 = data.input.actual,
                  let actual2 = data.output.actual {
                   print(actual1)
                   print(actual2)
               }
            }

        }

        frameGraph.compile();
        frameGraph.execute();
        frameGraph.exportGraphviz(filename: "framegraph");
        frameGraph.clear();
    }
}

struct texture_description {
    var name: String
}
extension texture_description: ResourceRealize {
    public typealias actual_type = String
    public func realize() -> String? {
        name
    }
}

typealias texture_2d_resource = Resource<texture_description>;

class render_task_0_data: RenderTaskDataType {
    var output: texture_2d_resource!
    required init() {}
}

class render_task_data: RenderTaskDataType {
    var input: texture_2d_resource!
    var output: texture_2d_resource!
    required init() {}
}
