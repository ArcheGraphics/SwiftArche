//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// The manager of the components.
class ComponentsManager {
    // Script
    private var _onStartScripts: DisorderedArray<Script> = DisorderedArray()
    private var _onUpdateScripts: DisorderedArray<Script> = DisorderedArray()
    private var _disableScripts: [Script] = []
    private var _destroyScripts: [Script] = []

    // Animation
    private var _onUpdateAnimations: DisorderedArray<Animator> = DisorderedArray()

    // Render
    var _renderers: DisorderedArray<Renderer> = DisorderedArray()

    // Delay dispose active/inActive Pool
    private var _componentsContainerPool: [[Component]] = [[]]
}

extension ComponentsManager {
    func addRenderer(_ renderer: Renderer) {
        renderer._rendererIndex = _renderers.count
        _renderers.add(renderer)
    }

    func removeRenderer(_ renderer: Renderer) {
        let replaced = _renderers.deleteByIndex(renderer._rendererIndex)
        if replaced != nil {
            replaced!._rendererIndex = renderer._rendererIndex
        }
        renderer._rendererIndex = -1
    }

    func addOnStartScript(_ script: Script) {
        script._onStartIndex = _onStartScripts.count
        _onStartScripts.add(script)
    }

    func removeOnStartScript(_ script: Script) {
        let replaced = _onStartScripts.deleteByIndex(script._onStartIndex)
        if replaced != nil {
            replaced!._onStartIndex = script._onStartIndex
        }
        script._onStartIndex = -1
    }

    func addOnUpdateScript(_ script: Script) {
        script._onUpdateIndex = _onUpdateScripts.count
        _onUpdateScripts.add(script)
    }

    func removeOnUpdateScript(_ script: Script) {
        let replaced = _onUpdateScripts.deleteByIndex(script._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = script._onUpdateIndex
        }
        script._onUpdateIndex = -1
    }

    func addDisableScript(component: Script) {
        _disableScripts.append(component)
    }

    func addDestroyScript(component: Script) {
        _destroyScripts.append(component)
    }

    func addOnUpdateAnimations(_ animation: Animator) {
        animation._onUpdateIndex = _onUpdateAnimations.count
        _onUpdateAnimations.add(animation)
    }

    func removeOnUpdateAnimations(_ animation: Animator) {
        let replaced = _onUpdateAnimations.deleteByIndex(animation._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = animation._onUpdateIndex
        }
        animation._onUpdateIndex = -1
    }

    //MARK: - Execute Components

    func callAnimationUpdate(_ deltaTime: Float) {
        let elements = _onUpdateAnimations._elements
        for i in 0..<_onUpdateAnimations.count {
            elements[i]!.update(deltaTime)
        }
    }

    func callRendererOnUpdate(_ deltaTime: Float) {
        let elements = _renderers._elements
        for i in 0..<_renderers.count {
            elements[i]!.update(deltaTime)
        }
    }

    func callScriptOnStart() {
        let onStartScripts = _onStartScripts
        if (onStartScripts.count > 0) {
            let elements = onStartScripts._elements
            // The 'onStartScripts.length' maybe add if you add some Script with addComponent() in some Script's onStart()
            for i in 0..<onStartScripts.count {
                let script = elements[i]!
                if (!script._waitHandlingInValid) {
                    script._started = true
                    script._onStartIndex = -1
                    script.onStart()
                }
            }
            onStartScripts.count = 0
        }
    }

    func callScriptOnUpdate(_ deltaTime: Float) {
        let elements = _onUpdateScripts._elements
        for i in 0..<_onUpdateScripts.count {
            let element = elements[i]!
            if (element._started) {
                element.onUpdate(deltaTime)
            }
        }
    }

    func callScriptOnLateUpdate(_ deltaTime: Float) {
        let elements = _onUpdateScripts._elements
        for i in 0..<_onUpdateScripts.count {
            let element = elements[i]!
            if (element._started) {
                element.onLateUpdate(deltaTime)
            }
        }
    }

    func callScriptOnPhysicsUpdate() {
        let elements = _onUpdateScripts._elements
        for i in 0..<_onUpdateScripts.count {
            let element = elements[i]!
            if (!element._waitHandlingInValid && element._started) {
                element.onPhysicsUpdate()
            }
        }
    }

    func callCameraOnBeginRender(_ camera: Camera,  _ commandBuffer: MTLCommandBuffer) {
        let camComps = camera.entity._scripts
        for i in 0..<camComps.count {
            camComps.get(i)?.onBeginRender(camera, commandBuffer)
        }
    }

    func callCameraOnEndRender(_ camera: Camera,  _ commandBuffer: MTLCommandBuffer) {
        let camComps = camera.entity._scripts
        for i in 0..<camComps.count {
            camComps.get(i)?.onEndRender(camera, commandBuffer)
        }
    }

    func handlingInvalidScripts() {
        var length = _disableScripts.count
        if (length > 0) {
            for disableScript in _disableScripts {
                if (disableScript._waitHandlingInValid) {
                    disableScript._handlingInValid()
                }
            }
            _disableScripts.removeAll()
        }

        length = _destroyScripts.count
        if (length > 0) {
            for destroyScript in _destroyScripts {
                destroyScript.onDestroy()
            }
            _destroyScripts.removeAll()
        }
    }
}

extension ComponentsManager {
    func getActiveChangedTempList() -> [Component] {
        (_componentsContainerPool.count != 0) ? _componentsContainerPool.first! : []
    }

    func putActiveChangedTempList(_ componentContainer: inout [Component]) {
        componentContainer = []
        _componentsContainerPool.append(componentContainer)
    }
}
