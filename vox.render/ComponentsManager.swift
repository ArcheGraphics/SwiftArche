//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The manager of the components.
class ComponentsManager {
    // Script
    private var _onStartScripts: DisorderedArray<Script> = DisorderedArray()
    private var _onUpdateScripts: DisorderedArray<Script> = DisorderedArray()
    private var _onLateUpdateScripts: DisorderedArray<Script> = DisorderedArray()
    private var _disableScripts: [Script] = [];
    private var _destroyScripts: [Script] = [];

    // Delay dispose active/inActive Pool
    private var _componentsContainerPool: [[Component]] = [[]]
}

extension ComponentsManager {
    func addOnStartScript(_ script: Script) {
        script._onStartIndex = _onStartScripts.length
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
        script._onUpdateIndex = _onUpdateScripts.length
        _onUpdateScripts.add(script)
    }

    func removeOnUpdateScript(_ script: Script) {
        let replaced = _onUpdateScripts.deleteByIndex(script._onUpdateIndex)
        if replaced != nil {
            replaced!._onUpdateIndex = script._onUpdateIndex
        }
        script._onUpdateIndex = -1
    }

    func addOnLateUpdateScript(_ script: Script) {
        script._onLateUpdateIndex = _onLateUpdateScripts.length
        _onLateUpdateScripts.add(script)
    }

    func removeOnLateUpdateScript(_ script: Script) {
        let replaced = _onLateUpdateScripts.deleteByIndex(script._onLateUpdateIndex)
        if replaced != nil {
            replaced!._onLateUpdateIndex = script._onLateUpdateIndex
        }
        script._onLateUpdateIndex = -1
    }

    func addDisableScript(component: Script) {
        _disableScripts.append(component);
    }

    func addDestroyScript(component: Script) {
        _destroyScripts.append(component);
    }

    //MARK: - Execute Components

    func callScriptOnStart() {
        let onStartScripts = _onStartScripts
        if (onStartScripts.length > 0) {
            let elements = onStartScripts._elements
            // The 'onStartScripts.length' maybe add if you add some Script with addComponent() in some Script's onStart()
            for i in 0..<onStartScripts.length {
                let script = elements[i]!
                if (!script._waitHandlingInValid) {
                    script._started = true
                    script._onStartIndex = -1
                    script.onStart()
                }
            }
            onStartScripts.length = 0
        }
    }

    func callScriptOnUpdate(_ deltaTime: Float) {
        let elements = _onUpdateScripts._elements
        for i in 0..<_onUpdateScripts.length {
            let element = elements[i]!
            if (element._started) {
                element.onUpdate(deltaTime)
            }
        }
    }

    func callScriptOnLateUpdate(_ deltaTime: Float) {
        let elements = _onLateUpdateScripts._elements
        for i in 0..<_onLateUpdateScripts.length {
            let element = elements[i]!
            if (element._started) {
                element.onLateUpdate(deltaTime)
            }
        }
    }

    func handlingInvalidScripts() {
        var length = _disableScripts.count;
        if (length > 0) {
            for disableScript in _disableScripts {
                if (disableScript._waitHandlingInValid) {
                    disableScript._handlingInValid();
                }
            }
            _disableScripts.removeAll()
        }

        length = _destroyScripts.count;
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
