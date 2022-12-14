//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import ImGui

class GUIManager {
    private let _engine: Engine
    
    init(_ engine:Engine) {
        _engine = engine
        
        _ = ImGuiCreateContext(nil)
        ImGuiStyleColorsDark(nil)
        
        ImGui_ImplMetal_Init(engine.device)
        ImGui_ImplOSX_Init(engine.canvas)
    }
    
    deinit {
        ImGui_ImplOSX_Shutdown()
    }
    
    func draw(_ commandBuffer: MTLCommandBuffer) {
        if let drawData = ImGuiGetDrawData() {
            let canvas = _engine.canvas
            if let renderPassDescriptor = canvas.currentRenderPassDescriptor {
                renderPassDescriptor.colorAttachments[0].loadAction = .load
                guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                    return
                }
                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                
                renderEncoder.label = "ImGui"
                renderEncoder.pushDebugGroup("ImGui")
                ImGui_ImplMetal_NewFrame(renderPassDescriptor)
                ImGui_ImplOSX_NewFrame(canvas)

                ImGui_ImplMetal_RenderDrawData(drawData.pointee, commandBuffer, renderEncoder)
                renderEncoder.popDebugGroup()
                renderEncoder.endEncoding()
            }
        }
    }
}
