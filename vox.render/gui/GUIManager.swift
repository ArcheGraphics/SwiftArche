//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ImGui
import Metal

class GUIManager {
    private var _onGUIScripts: DisorderedArray<Script> = DisorderedArray()

    final class GUIEncoderData: EmptyClassType {
        var output: Resource<MTLTextureDescriptor>?
        required init() {}
    }

    init() {
        #if os(macOS)
            _ = ImGuiCreateContext(nil)
            ImGuiStyleColorsDark(nil)

            ImGui_ImplMetal_Init(Engine.device)
            ImGui_ImplOSX_Init(Engine.canvas)
        #endif
        let material = BaseMaterial()
        material.shader = Shader.create(in: Engine.library(), vertexSource: "vertex_text",
                                        fragmentSource: "fragment_text")
        material.name = "default text"
        material.isTransparent = true
        material.renderStates[0].rasterState.cullMode = .front
        TextRenderer._defaultMaterial = material
    }

    func destroy() {
        #if os(macOS)
            ImGui_ImplOSX_Shutdown()
        #endif
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
        for i in 0 ..< _onGUIScripts.count {
            let element = elements[i]!
            if element._started {
                element.onGUI()
            }
        }
    }

    func draw(_ commandBuffer: MTLCommandBuffer) {
        callScriptOnGUI()

        if PointBatcher.ins.containData || LineBatcher.ins.containData
            || TriangleBatcher.ins.containData || TextBatcher.ins.containData
        {
            Engine.fg.addFrameTask(for: GUIEncoderData.self, name: "gizmo",
                                   commandBuffer: commandBuffer)
            { data, builder in
                let colorTex = Engine.fg.blackboard[BlackBoardType.color.rawValue] as! Resource<MTLTextureDescriptor>
                data.output = builder.write(resource: colorTex)
            } execute: { _, commandBuffer in
                let canvas = Engine.canvas!
                if let commandBuffer,
                   let camera = Camera.mainCamera,
                   let renderPassDescriptor = canvas.currentRenderPassDescriptor
                {
                    renderPassDescriptor.colorAttachments[0].loadAction = .load
                    var encoder = RenderCommandEncoder(commandBuffer, renderPassDescriptor, "gizmos")
                    if PointBatcher.ins.containData {
                        PointBatcher.ins.drawBatcher(&encoder, camera)
                    }
                    if LineBatcher.ins.containData {
                        LineBatcher.ins.drawBatcher(&encoder, camera)
                    }
                    if TriangleBatcher.ins.containData {
                        TriangleBatcher.ins.drawBatcher(&encoder, camera)
                    }
                    if TextBatcher.ins.containData {
                        TextBatcher.ins.drawBatcher(&encoder, camera)
                    }
                    encoder.endEncoding()
                    renderPassDescriptor.colorAttachments[0].loadAction = .clear
                }
            }
        }
        #if os(macOS)
            // GUI
            if ImGuiGetDrawData() != nil {
                Engine.fg.addFrameTask(for: GUIEncoderData.self, name: "gui",
                                       commandBuffer: commandBuffer)
                { data, builder in
                    let colorTex = Engine.fg.blackboard[BlackBoardType.color.rawValue] as! Resource<MTLTextureDescriptor>
                    data.output = builder.write(resource: colorTex)
                } execute: { _, commandBuffer in
                    let canvas = Engine.canvas!
                    if let commandBuffer,
                       let drawData = ImGuiGetDrawData(),
                       let renderPassDescriptor = canvas.currentRenderPassDescriptor
                    {
                        renderPassDescriptor.colorAttachments[0].loadAction = .load
                        let encoder = RenderCommandEncoder(commandBuffer, renderPassDescriptor, "ImGui")
                        encoder.handle.pushDebugGroup("ImGui")
                        ImGui_ImplMetal_NewFrame(renderPassDescriptor)
                        ImGui_ImplOSX_NewFrame(canvas)

                        ImGui_ImplMetal_RenderDrawData(drawData.pointee, commandBuffer, encoder.handle)
                        encoder.handle.popDebugGroup()
                        encoder.handle.endEncoding()
                        renderPassDescriptor.colorAttachments[0].loadAction = .clear
                    }
                }
            }
        #endif
    }
}
