//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Scene manager.
public class SceneManager {
    var _allScenes: [Scene] = []
    var _activeScene: Scene?
    private var _engine: Engine

    /// The activated scene.
    public var activeScene: Scene? {
        get {
            _activeScene
        }
        set {
            let oldScene = _activeScene
            if (oldScene !== newValue) {
                oldScene?._processActive(false)
                newValue?._processActive(true)
                _activeScene = newValue
            }
        }
    }

    init(engine: Engine) {
        _engine = engine
    }

    /// Merge the source scene into the target scene.
    /// - Parameters:
    ///   - sourceScene: source scene
    ///   - destScene: target scene
    /// - Remark: the global information of destScene will be used after the merge, and the lightingMap information will be merged.
    public func mergeScenes(_ sourceScene: Scene, _ destScene: Scene) {
        let oldRootEntities = sourceScene.rootEntities
        for i in 0..<oldRootEntities.count {
            destScene.addRootEntity(oldRootEntities[i])
        }
    }

    ///
    /// Load and activate scene.
    /// - Parameters:
    ///   - url: the path of the scene
    ///   - destroyOldScene: whether to destroy old scene information
    public func loadScene(url: String, destroyOldScene: Bool = true) {
    }
}
