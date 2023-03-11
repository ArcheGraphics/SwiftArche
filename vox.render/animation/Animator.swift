//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// The controller of the animation system.
public class Animator: Component {
    var _onUpdateIndex: Int = -1

    /// Evaluates the animator component based on deltaTime.
    /// - Parameter deltaTime: The deltaTime when the animation update
    func update(_ deltaTime: Float) {
    }

    internal override func _onEnable() {
        engine._componentsManager.addOnUpdateAnimations(self)
    }

    internal override func _onDisable() {
        engine._componentsManager.removeOnUpdateAnimations(self)
    }
}
