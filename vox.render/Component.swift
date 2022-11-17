//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The base class of the components.
public class Component: EngineObject {
    var _entity: Entity
    var _awoken: Bool = false

    private var _phasedActive: Bool = false
    private var _enabled: Bool = true

    required init(_ entity: Entity) {
        _entity = entity
        super.init(entity.engine)
    }

    /// Destroy this instance.
    deinit {
        _entity._removeComponent(self)
        if (_entity.isActiveInHierarchy) {
            if _enabled {
                _onDisable()
            }
        }
        _onDestroy()
    }

    /// Indicates whether the component is enabled.
    public var enabled: Bool {
        get {
            _enabled
        }
        set {
            if (newValue != _enabled) {
                _enabled = newValue
                if (_entity.isActiveInHierarchy) {
                    if (newValue) {
                        _phasedActive = true
                        _onEnable()

                    } else {
                        _phasedActive = false
                        _onDisable()
                    }
                }
            }
        }
    }

    /// The entity which the component belongs to.
    public var entity: Entity {
        get {
            _entity
        }
    }

    /// The scene which the component's entity belongs to.
    public var scene: Scene {
        get {
            _entity.scene
        }
    }

    func _onAwake() {
    }

    func _onEnable() {
    }

    func _onDisable() {
    }

    func _onDestroy() {
    }

    func _setActive(_ value: Bool) {
        if (value) {
            // Awake condition is un awake && current entity is active in hierarchy
            if (!_awoken && entity._isActiveInHierarchy) {
                _awoken = true
                _onAwake()
            }
            // Developer maybe do `isActive = false` in `onAwake` method
            // Enable condition is phased active state is false && current compoment is active in hierarchy
            if (!_phasedActive && entity._isActiveInHierarchy && _enabled) {
                _phasedActive = true
                _onEnable()
            }
        } else {
            // Disable condition is phased active state is true && current compoment is inActive in hierarchy
            if (_phasedActive && !(entity._isActiveInHierarchy && _enabled)) {
                _phasedActive = false
                _onDisable()
            }
        }
    }
}
