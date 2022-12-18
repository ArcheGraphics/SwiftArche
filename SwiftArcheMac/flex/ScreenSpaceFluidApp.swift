//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import vox_flex
import ImGui

fileprivate class GUI: Script {
    var ssf: ScreenSpaceFluid!
    
    private var kernelRadius: Int32 {
        get {
            Int32(ssf.kernelRadius)
        }
        set {
            ssf.kernelRadius = Int(newValue)
        }
    }
    
    override func onUpdate(_ deltaTime: Float) {
        UIElement.Init(engine.canvas, deltaTime)

        ImGuiNewFrame()
        ImGuiSliderFloat("point radius", &ssf.pointRadius, 0.0, 50.0, nil, 1)
        ImGuiSliderInt("kernelRadius", &kernelRadius, 0, 50, nil, ImGuiSliderFlags())
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
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let skyMaterial = SkyBoxMaterial(engine)
        skyMaterial.textureCubeMap = hdr
        skyMaterial.equirectangular = true
        let skySubpass = SkySubpass()
        skySubpass.material = skyMaterial
        skySubpass.mesh = PrimitiveMesh.createCuboid(engine)
        scene.background.mode = .Sky
        scene.background.sky = skySubpass
    }
    
    func createSDF() -> ImplicitTriangleMesh {
        let assetURL = Bundle.main.url(forResource: "bunny", withExtension: "obj", subdirectory: "assets")!
        let triangleMesh = TriangleMesh(device: engine.device)!
        triangleMesh.load(assetURL)
        
        return ImplicitTriangleMesh.builder()
            .withTriangleMesh(triangleMesh)
            .withResolutionX(100)
            .build(engine)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)

        let scene = engine.sceneManager.activeScene!
        loadHDR(scene)
        let rootEntity = scene.createRootEntity()
        let gui: GUI = rootEntity.addComponent()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(2, 2, 2)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
        
        let particleSystem = ParticleSystemData(engine, maxLength: 10000)
        
        let emitter = VolumeParticleEmitter(engine)
        emitter.target = particleSystem
        emitter.maxRegion = BoundingBox3F(point1: Vector3F(-1, -1, -1), point2: Vector3F(1, 1, 1))
        emitter.spacing = 0.02
        emitter.implicitSurface = createSDF()
        // emitter.maxNumberOfParticles = 100
        // todo
        emitter.resourceCache = scene.postprocessManager.postProcessPass.resourceCache!
        if let commandBuffer = engine.commandQueue.makeCommandBuffer() {
            if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                emitter.update(commandEncoder, currentTimeInSeconds: 0, timeIntervalInSeconds: 0)
                commandEncoder.endEncoding()
            }
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        
        let ssf: ScreenSpaceFluid = cameraEntity.addComponent()
        ssf.particleSystem = particleSystem
        gui.ssf = ssf
        
        engine.run()
    }
}

