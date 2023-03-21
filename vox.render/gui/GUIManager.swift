//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import ImGui

class GUIManager {
    private var _renderPass: RenderPass!
    private var _onGUIScripts: DisorderedArray<Script> = DisorderedArray()
    private var _resourceCache: ResourceCache!

    init() {
        _ = ImGuiCreateContext(nil)
        ImGuiStyleColorsDark(nil)
        
        ImGui_ImplMetal_Init(Engine.device)
        ImGui_ImplOSX_Init(Engine.canvas)
        
        _resourceCache = ResourceCache(Engine.device)

        let shader = ShaderPass(Engine.library(), "vertex_text", "fragment_text")
        shader.setRenderQueueType(.Transparent)
        shader._renderState!.rasterState.cullMode = .front
        let material = Material("default text")
        material.shader.append(shader)
        TextRenderer._defaultMaterial = material
    }
    
    func destroy() {
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
        
        let canvas = Engine.canvas!
        if let renderPassDescriptor = canvas.currentRenderPassDescriptor {
            renderPassDescriptor.colorAttachments[0].loadAction = .load
            // Gizmos
            if let camera = Camera.mainCamera,
               PointBatcher.ins.containData || LineBatcher.ins.containData
                || TriangleBatcher.ins.containData || TextBatcher.ins.containData {
                var encoder = RenderCommandEncoder(commandBuffer, renderPassDescriptor, "gizmos")
                if PointBatcher.ins.containData {
                    PointBatcher.ins.drawBatcher(&encoder, camera, _resourceCache)
                }
                if LineBatcher.ins.containData {
                    LineBatcher.ins.drawBatcher(&encoder, camera, _resourceCache)
                }
                if TriangleBatcher.ins.containData {
                    TriangleBatcher.ins.drawBatcher(&encoder, camera, _resourceCache)
                }
                if TextBatcher.ins.containData {
                    TextBatcher.ins.drawBatcher(&encoder, camera, _resourceCache)
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
