//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import ImGui

class GUIManager {
    private var _renderPass: RenderPass!
    private let _engine: Engine
    private var _onGUIScripts: DisorderedArray<Script> = DisorderedArray()

    init(_ engine:Engine) {
        _engine = engine
        
        _ = ImGuiCreateContext(nil)
        ImGuiStyleColorsDark(nil)
        
        ImGui_ImplMetal_Init(engine.device)
        ImGui_ImplOSX_Init(engine.canvas)
        
        PointSubpass.ins.set(engine)
        LineSubpass.ins.set(engine)
        TriangleSubpass.ins.set(engine)
    }
    
    deinit {
        ImGui_ImplOSX_Shutdown()
    }
    
    func addOnGUIScript(_ script: Script) {
        script._onGUIIndex = _onGUIScripts.count
        _onGUIScripts.add(script)
    }

    func removeOnGUIScript(_ script: Script) {
        let replaced = _onGUIScripts.deleteByIndex(script._onGUIIndex)
        if replaced != nil {
            replaced!._onGUIIndex = script._onGUIIndex
        }
        script._onGUIIndex = -1
    }
    
    func callScriptOnGUI() {
        let elements = _onGUIScripts._elements
        for i in 0..<_onGUIScripts.count {
            let element = elements[i]!
            if (element._started) {
                element.onGUI()
            }
        }
    }
    
    func draw(_ commandBuffer: MTLCommandBuffer) {
        callScriptOnGUI()
        
        let canvas = _engine.canvas
        if let renderPassDescriptor = canvas.currentRenderPassDescriptor {
            renderPassDescriptor.colorAttachments[0].loadAction = .load
            // Gizmos
            if PointSubpass.ins.containData || LineSubpass.ins.containData || TriangleSubpass.ins.containData {
                var encoder = RenderCommandEncoder(commandBuffer, renderPassDescriptor, "gizmos")
                if PointSubpass.ins.containData {
                    PointSubpass.ins.draw(&encoder)
                }
                if LineSubpass.ins.containData {
                    LineSubpass.ins.draw(&encoder)
                }
                if TriangleSubpass.ins.containData {
                    TriangleSubpass.ins.draw(&encoder)
                }
                encoder.endEncoding()
            }
            
            // GUI
            if let drawData = ImGuiGetDrawData() {
                guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                    return
                }
                renderEncoder.label = "ImGui"
                renderEncoder.pushDebugGroup("ImGui")
                ImGui_ImplMetal_NewFrame(renderPassDescriptor)
                ImGui_ImplOSX_NewFrame(canvas)
                
                ImGui_ImplMetal_RenderDrawData(drawData.pointee, commandBuffer, renderEncoder)
                renderEncoder.popDebugGroup()
                renderEncoder.endEncoding()
            }
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
        }
    }
}
