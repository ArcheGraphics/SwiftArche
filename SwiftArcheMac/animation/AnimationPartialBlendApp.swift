//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit
import ImGui

fileprivate class GUI: Script {
    var lower_body_sampler: AnimationClip?
    var upper_body_sampler: AnimationClip?
    var lowerMask: Float = 0
    var upperMask: Float = 1
    
    override func onGUI() {
        if let lower_body_sampler,
           let upper_body_sampler {
            UIElement.Init(engine)
            
            ImGuiNewFrame()
            ImGuiSliderFloat("Clip Lower Weight", &lower_body_sampler.weight, 0.0, 1.0, nil, 1)
            ImGuiSliderFloat("Clip Lower Joint Mask", &lowerMask, 0.0, 1.0, nil, 1)
            ImGuiSliderFloat("Clip Upper Weight", &upper_body_sampler.weight, 0.0, 1.0, nil, 1)
            ImGuiSliderFloat("Clip Upper Joint Mask", &upperMask, 0.0, 1.0, nil, 1)
            // Rendering
            ImGuiRender()
        }
        setupPerJointWeights()
    }
    
    func setupPerJointWeights() {
        // Setup partial animation mask. This mask is defined by a weight_setting
        // assigned to each joint of the hierarchy. Joint to disable are set to a
        // weight_setting of 0.f, and enabled joints are set to 1.f.
        // Per-joint weights of lower and upper body layers have opposed values
        // (weight_setting and 1 - weight_setting) in order for a layer to select
        // joints that are rejected by the other layer.
        if let lower_body_sampler,
           let upper_body_sampler {
            lower_body_sampler.setJointMasks(1.0)
            lower_body_sampler.setJointMasks(lowerMask, root: "Spine1")
            upper_body_sampler.setJointMasks(0.0)
            upper_body_sampler.setJointMasks(upperMask, root: "Spine1")
        }
    }
}

class AnimationPartialBlendApp: NSViewController {
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
        cameraEntity.transform.position = Vector3(2, 2, 6)
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
        let lower_body_sampler = AnimationClip(url)
        gui.lower_body_sampler = lower_body_sampler

        url = Bundle.main.url(forResource: "pab_crossarms",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let upper_body_sampler = AnimationClip(url)
        gui.upper_body_sampler = upper_body_sampler
        
        let animationBlending = AnimationBlending()
        animationBlending.addChild(state: lower_body_sampler)
        animationBlending.addChild(state: upper_body_sampler)
        animator.rootState = animationBlending
        
        characterEntity.addComponent(AnimationVisualizer.self)

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

