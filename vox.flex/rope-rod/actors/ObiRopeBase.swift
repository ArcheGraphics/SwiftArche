//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRopeBase: ObiActor {
    var m_SelfCollisions = false
    var restLength_: Float = 0
    public var elements: [ObiStructuralElement] = []

    /// Calculates and returns current rope length, including stretching/compression.
    public func CalculateLength() -> Float {
        0
    }

    /// Recalculates the rope's rest length, that is, its length as specified by the blueprint.
    public func RecalculateRestLength() {}

    /// Recalculates all particle rest positions, used when filtering self-collisions.
    public func RecalculateRestPositions() {}

    /// Regenerates all rope elements using constraints. It's the opposite of RebuildConstraintsFromElements().
    /// This is automatically called when loading a blueprint, but should also be called when manually
    /// altering rope constraints (adding/removing/updating constraints and/or batches).
    public func RebuildElementsFromConstraints() {}

    func RebuildElementsFromConstraintsInternal() {}

    /// Regenerates all rope constraints using rope elements. It's the opposite of RebuildElementsFromConstraints().This should be called anytime the element representation of the rope
    /// is changed (adding/removing/updating elements). This is usually the case after tearing the rope or changing its length using a cursor.
    public func RebuildConstraintsFromElements() {}

    /// Returns a rope element that contains a length-normalized coordinate. It will also return the length-normalized coordinate within the element.
    public func GetElementAt(mu _: Float, elementMu _: inout Float) -> ObiStructuralElement? {
        nil
    }
}
