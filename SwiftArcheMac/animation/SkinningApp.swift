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

class SkinningApp: NSViewController {
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
        cameraEntity.transform.position = Vector3(3, 2, 3)
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
        baseSampler.weight = 1.0
        let animationBlending = AnimationBlending()
        animationBlending.addChild(state: baseSampler)
        animator.rootState = animationBlending
        
        url = Bundle.main.url(forResource: "ruby_mesh",
                              withExtension: "ozz",
                              subdirectory: "assets/Animation")!
        let skinGroup = SkinGroup(url)
        for i in 0..<skinGroup.count {
            let renderer = characterEntity.addComponent(SkinnedMeshRenderer.self)
            renderer.setSkinnedMesh(with: skinGroup, at: i)
            let material = PBRMaterial(engine);
            material.baseColor = Color(0.4, 0.6, 0.6, 0.6)
            material.isTransparent = true
            renderer.setMaterial(material)
        }

        characterEntity.addComponent(AnimationVisualizer.self)

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}
