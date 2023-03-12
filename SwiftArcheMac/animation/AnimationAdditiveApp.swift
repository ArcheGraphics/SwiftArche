//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class AnimationAdditiveApp: NSViewController {
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

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

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
        
        url = Bundle.main.url(forResource: "pab_curl_additive",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let sampler0 = AnimationClip(url)
        sampler0.blendMode = .Additive
        
        url = Bundle.main.url(forResource: "pab_splay_additive",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let sampler1 = AnimationClip(url)
        sampler1.blendMode = .Additive
        
        let animationBlending = AnimationBlending()
        animationBlending.addChild(state: sampler0)
        animationBlending.addChild(state: sampler1)
        animationBlending.addChild(state: baseSampler)
        animator.rootState = animationBlending
        
        characterEntity.addComponent(AnimationVisualizer.self)

        engine.run()
    }
}

