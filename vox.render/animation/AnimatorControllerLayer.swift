//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The Animation Layer contains a state machine that controls animations of a model or part of it.
public class AnimatorControllerLayer {
    /// The blending weight that the layers has. It is not taken into account for the first layer.
    public var weight: Float = 1.0
    /// The blending mode used by the layer. It is not taken into account for the first layer.
    public var blendingMode: AnimatorLayerBlendingMode = AnimatorLayerBlendingMode.Override
    /// The state machine for the layer.
    public var stateMachine: AnimatorStateMachine!

    /// The layer's name
    public var name: String

    init(_ name: String) {
        self.name = name
    }
}
