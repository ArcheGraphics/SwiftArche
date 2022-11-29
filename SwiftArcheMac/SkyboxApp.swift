//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import ImGui

fileprivate class GUI: Script {
    var show_demo_window: Bool = true
    var show_another_window: Bool = false
    var clear_color: SIMD3<Float> = .init(x: 0.28, y: 0.36, z: 0.5)
    var f: Float = 0.0
    var counter: Int = 0

    override func onUpdate(_ deltaTime: Float) {
        let view = engine.canvas
        let io = ImGuiGetIO()!
        io.pointee.DisplaySize.x = Float(view.bounds.size.width)
        io.pointee.DisplaySize.y = Float(view.bounds.size.height)
        let frameBufferScale = Float(view.window?.screen?.backingScaleFactor ?? NSScreen.main!.backingScaleFactor)
        io.pointee.DisplayFramebufferScale = ImVec2(x: frameBufferScale, y: frameBufferScale)
        io.pointee.DeltaTime = deltaTime

        ImGuiNewFrame()

        // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()!
        // You can browse its code to learn more about Dear ImGui!).
        if show_demo_window {
            ImGuiShowDemoWindow(&show_demo_window)
        }

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.

        // Create a window called "Hello, world!" and append into it.
        ImGuiBegin("Begin", &show_demo_window, 0)

        // Display some text (you can use a format strings too)
        ImGuiTextV("This is some useful text.")

        // Edit bools storing our window open/close state
        ImGuiCheckbox("Demo Window", &show_demo_window)
        ImGuiCheckbox("Another Window", &show_another_window)

        ImGuiSliderFloat("Float Slider", &f, 0.0, 1.0, nil, 1) // Edit 1 float using a slider from 0.0f to 1.0f

        ImGuiColorEdit3("clear color", &clear_color, 0) // Edit 3 floats representing a color

        if ImGuiButton("Button", ImVec2(x: 100, y: 20)) { // Buttons return true when clicked (most widgets return true when edited/activated)
            counter += 1
        }

        //SameLine(offset_from_start_x: 0, spacing: 0)

        ImGuiSameLine(0, 2)
        ImGuiTextV(String(format: "counter = %d", counter))

        let avg: Float = (1000.0 / io.pointee.Framerate)
        let fps = io.pointee.Framerate

        ImGuiTextV(String(format: "Application average %.3f ms/frame (%.1f FPS)", avg, fps))

        ImGuiEnd()
        // Rendering
        ImGuiRender()
    }
}

class SkyboxApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)

        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()
        let _: GUI = rootEntity.addComponent()

        let skyMaterial = SkyBoxMaterial(engine)
        skyMaterial.textureCubeMap = try! engine.textureLoader.loadTexture(with: "country")!

        let skySubpass = SkySubpass()
        skySubpass.material = skyMaterial
        skySubpass.mesh = PrimitiveMesh.createCuboid(engine)

        scene.background.mode = .Sky
        scene.background.sky = skySubpass

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 1, y: 1, z: 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        let cubeEntity = rootEntity.createChild()
        let renderer: MeshRenderer = cubeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.1)
        let material = UnlitMaterial(engine)
        material.baseColor = Color(0.4, 0.0, 0.0)
        renderer.setMaterial(material)

        engine.run()
    }
}

