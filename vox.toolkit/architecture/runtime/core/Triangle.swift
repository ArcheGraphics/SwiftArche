//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

struct Triangle {
    var m_A: Int

    var m_B: Int

    var m_C: Int

    public var a: Int {
        get {
            m_A
        }
    }

    public var b: Int {
        get {
            m_B
        }
    }

    public var c: Int {
        get {
            m_C
        }
    }

    public var indices: [Int] {
        get {
            [m_A, m_B, m_C]
        }
    }

    public init(a: Int, b: Int, c: Int) {
        m_A = a
        m_B = b
        m_C = c
    }

    public func IsAdjacent(other: Triangle) -> Bool {
        other.ContainsEdge(Edge(a, b))
                || other.ContainsEdge(Edge(b, c))
                || other.ContainsEdge(Edge(c, a))
    }

    func ContainsEdge(_ edge: Edge) -> Bool {
        if (Edge(a, b) == edge) {
            return true
        }
        if (Edge(b, c) == edge) {
            return true
        }
        return Edge(c, a) == edge
    }
}

extension Triangle: Hashable {
    
}
