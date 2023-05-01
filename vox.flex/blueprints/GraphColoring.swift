//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// General greedy graph coloring algorithm for constraints. Input:
/// - List of particle indices used by all constraints.
/// - List of per-constraint offsets of the first constrained particle in the previous array, with the total amount of particle indices in the last position.
///
/// The output is a color for each constraint. Constraints of the same color are guaranteed to not share any partices.
public class GraphColoring {
    public private(set) var particleIndices: [Int] = []
    public private(set) var constraintIndices: [Int] = []
    private var m_ConstraintsPerParticle: [[Int]] = []

    public init(particleCount: Int = 0) {
        m_ConstraintsPerParticle = .init(repeating: [], count: particleCount)
        for _ in 0 ..< particleCount {
            m_ConstraintsPerParticle.append([])
        }
    }

    public func Clear() {}

    public func AddConstraint(particles _: [Int]) {}

    public func Colorize(progressDescription _: String, colors _: [Int]) {}
}
