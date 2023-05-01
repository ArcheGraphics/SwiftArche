//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRopeCursor: Script {
    var rope: ObiRope?

    private var m_CursorMu: Float = 0

    private var m_SourceMu: Float = 0

    public var direction = true

    var m_CursorElement: ObiStructuralElement? = nil
    private var m_SourceIndex: Int = -1

    private func Actor_OnElementsGenerated(actor _: ObiActor) {}

    public func UpdateCursor() {}

    public func UpdateSource() {}

    private func AddParticleAt(index _: Int) -> Int {
        0
    }

    private func RemoveParticleAt(index _: Int) {}

    public func ChangeLength(newLength _: Float) {}
}
