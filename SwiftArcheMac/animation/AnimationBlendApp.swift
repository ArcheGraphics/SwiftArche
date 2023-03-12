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
    var sampler0: AnimationClip?
    var sampler1: AnimationClip?
    var sampler2: AnimationClip?

    override func onGUI() {
        if let sampler0,
           let sampler1,
           let sampler2 {
            UIElement.Init(engine)
            
            ImGuiNewFrame()
            ImGuiSliderFloat("Clip Jog Weight", &sampler0.weight, 0.0, 1.0, nil, 1)
            ImGuiSliderFloat("Clip Walk Weight", &sampler1.weight, 0.0, 1.0, nil, 1)
            ImGuiSliderFloat("Clip Run Weight", &sampler2.weight, 0.0, 1.0, nil, 1)
            // Rendering
            ImGuiRender()
        }
    }
}

class AnimationBlendApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()
        let gui = rootEntity.addComponent(GUI.self)

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(1.2, 1.5, 0)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self).target = Vector3(0, 1, 0)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        let characterEntity = rootEntity.createChild()
        let animator = characterEntity.addComponent(Animator.self)
        var url = Bundle.main.url(forResource: "pab_skeleton",
                                  withExtension: "ozz",
                                  subdirectory: "assets/Animation")!
        animator.loadSkeleton(url)
        
        url = Bundle.main.url(forResource: "pab_walk",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let baseSampler = AnimationClip(url)
        gui.sampler0 = baseSampler

        url = Bundle.main.url(forResource: "pab_jog",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let sampler0 = AnimationClip(url)
        gui.sampler1 = sampler0

        url = Bundle.main.url(forResource: "pab_run",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let sampler1 = AnimationClip(url)
        gui.sampler2 = sampler1
        
        let animationBlending = AnimationBlending()
        animationBlending.addChild(state: sampler0)
        animationBlending.addChild(state: sampler1)
        animationBlending.addChild(state: baseSampler)
        animator.rootState = animationBlending
        
        characterEntity.addComponent(AnimationVisualizer.self)

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

