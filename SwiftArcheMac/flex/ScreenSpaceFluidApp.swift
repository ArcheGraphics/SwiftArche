//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import ImGui
import Math
import vox_flex
import vox_render
import vox_toolkit

private class GUI: Script {
    var ssf: ScreenSpaceFluid!

    private var kernelRadius: Int32 {
        get {
            Int32(ssf.kernelRadius)
        }
        set {
            ssf.kernelRadius = Int(newValue)
        }
    }

    override func onGUI() {
        UIElement.Init()

        ImGuiNewFrame()
        ImGuiSliderFloat("point radius", &ssf.pointRadius, 0.0, 100.0, nil, 1)
        ImGuiSliderInt("smooth iter count", &ssf.smoothIter, 0, 10, nil, ImGuiSliderFlags())
        ImGuiSliderInt("kernel radius", &kernelRadius, 0, 10, nil, ImGuiSliderFlags())
        ImGuiSliderFloat("sigma radius", &ssf.sigmaRadius, 0.0, 50.0, nil, 1)
        ImGuiSliderFloat("sigma depth", &ssf.sigmaDepth, 0.0, 50.0, nil, 1)

        ImGuiSeparator()
        UIElement.frameRate()
        ImGuiRender()
    }
}

class ScreenSpaceFluidApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    func loadHDR(_ scene: Scene) {
        let hdr = Engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let skyMaterial = SkyBoxMaterial()
        skyMaterial.textureCubeMap = hdr
        skyMaterial.equirectangular = true
        let skySubpass = SkySubpass()
        skySubpass.material = skyMaterial
        skySubpass.mesh = PrimitiveMesh.createCuboid()
        scene.background.mode = .Sky
        scene.background.sky = skySubpass
    }

    func createSDF() -> ImplicitTriangleMesh {
        let assetURL = Bundle.main.url(forResource: "bunny", withExtension: "obj", subdirectory: "assets")!
        let triangleMesh = TriangleMesh(device: Engine.device)!
        triangleMesh.load(assetURL)

        return ImplicitTriangleMesh.builder()
            .withTriangleMesh(triangleMesh)
            .withResolutionX(100)
            .build()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker()

        let scene = Engine.sceneManager.activeScene!
        loadHDR(scene)
        let rootEntity = scene.createRootEntity()
        let gui = rootEntity.addComponent(GUI.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(2, 2, 2)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let particleSystem = ParticleSystemData(maxLength: 10000)

        let emitter = VolumeParticleEmitter()
        emitter.target = particleSystem
        emitter.maxRegion = BoundingBox3F(point1: Vector3F(-1, -1, -1), point2: Vector3F(1, 1, 1))
        emitter.spacing = 0.02
        emitter.implicitSurface = createSDF()
        // emitter.maxNumberOfParticles = 100
        // todo
        emitter.resourceCache = scene.postprocessManager.postProcessPass.resourceCache!
        if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
            if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                emitter.update(commandEncoder, currentTimeInSeconds: 0, timeIntervalInSeconds: 0)
                commandEncoder.endEncoding()
            }
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }

        let ssf = cameraEntity.addComponent(ScreenSpaceFluid.self)
        ssf.particleSystem = particleSystem
        gui.ssf = ssf

        Engine.run()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}
