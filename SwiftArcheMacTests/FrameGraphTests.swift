//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
import vox_render

final class FrameGraphTests: XCTestCase {
    // Graphviz located in ~/Library/Containers/archegraphics.SwiftArcheMac/Data/Documents
    func testSelfDefineFrameGraph() throws {
        var frameGraph = FrameGraph(size: 0)
        
        let backbuffer = Texture("render target")
        let retained_resource = frameGraph.addRetainedResource(for: TextureDescription.self, name: "swapchain",
                                                               description: TextureDescription(name: "framebuffer"),
                                                               actual: backbuffer)
        
        // MARK: - Pass
        let render_task_0: FrameTask<FrameTaskData0> =
        frameGraph.addFrameTask(for: FrameTaskData0.self, name: "Render Task 0", commandBuffer: nil) { data, builder in
            data.output = builder.write(resource: builder.read(resource: builder.create(name: "Resource 0",
                                                                                        description: TextureDescription(name: "0"))));
        } execute: { data, commandBuffer in
            if let actual1 = data.output.actual {
                print("Render Task 0 with \(actual1)")
            }
        }
        
        // MARK: - Pass
        let data_0 = render_task_0.data
        var render_task: FrameTask<FrameTaskData>!
        for i in 1...4 {
            let internal_render_task: FrameTask<FrameTaskData> =
            frameGraph.addFrameTask(for: FrameTaskData.self, name: "Render Task \(i)", commandBuffer: nil) { data, builder in
                data.input = builder.read(resource: data_0.output);
                data.output = builder.write(resource: builder.create(name: "Resource \(i)", description: TextureDescription(name: String(i))))
            } execute: { data, commandBuffer in
               if let actual1 = data.input.actual,
                  let actual2 = data.output.actual {
                   print("Render Task \(i) with \(actual1)")
                   print("Render Task \(i) with \(actual2)")
               }
            }
            
            if i == 1 {
                render_task = internal_render_task
            }
        }
        
        // MARK: - Pass
        let data_final = render_task.data
        frameGraph.addFrameTask(for: FrameTaskData.self, name: "Final Render Task", commandBuffer: nil) { data, builder in
            data.input = builder.read(resource: data_final.output);
            data.output = builder.write(resource: retained_resource)
        } execute: { data, commandBuffer in
           if let actual1 = data.input.actual,
              let actual2 = data.output.actual {
               print("Final Render Task with \(actual1)")
               print("Final Render Task with \(actual2)")
           }
        }

        frameGraph.compile();
        frameGraph.execute();
        frameGraph.exportGraphviz(filename: "framegraph");
        frameGraph.clear();
    }
}

class Texture {
    var string: String
    init(_ string: String) {
        self.string = string
    }
}

extension Texture: CustomStringConvertible {
    var description: String {
        string
    }
}

struct TextureDescription {
    var name: String
}
extension TextureDescription: ResourceRealize {
    public typealias actual_type = Texture
    
    func realize(with heap: MTLHeap?) -> Texture? {
        Texture(name)
    }
    
    func derealize(resource: Texture) {}
    
    var size: Int { 0 }
}

typealias Texture2DResource = Resource<TextureDescription>;

class FrameTaskData0: EmptyClassType {
    var output: Texture2DResource!
    required init() {}
}

class FrameTaskData: EmptyClassType {
    var input: Texture2DResource!
    var output: Texture2DResource!
    required init() {}
}
