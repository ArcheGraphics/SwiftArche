//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

///
///  MultilevelGrid is the most used spatial partitioning structure in Obi. It is:
///
/// - Unbounded: defines no limits on the size of location of space partitioned.
/// - Sparse: only allocates memory where space has interesting features to track.
/// - Multilevel: can store several levels of spatial subdivision, from very fine to very large.
/// - Implicit: the hierarchical relationship between cells is not stored in memory,
///   but implicitly derived from the structure itself.
///
///  These characteristics make it extremely flexible, memory efficient, and fast.
///  Its implementation is also fairly simple and concise.
///
public struct NativeMultilevelGrid<T> where T: Equatable {
    public let minSize: Float = 0.01

    /// A cell in the multilevel grid. Coords are 4-dimensional, the 4th component is the grid level.
    public struct Cell<K> where K: Equatable {
        var coords: int4
        var contents: [K] = []

        public init(coords: int4) {
            self.coords = coords
        }

        public var Coords: int4 { return coords }

        public var Length: Int { return contents.count }

        public subscript(index: Int) -> K {
            contents[index]
        }

        public mutating func Add(entity: K) {
            contents.append(entity)
        }

        public mutating func Remove(entity: K) -> Bool {
            let index = contents.firstIndex { e in
                e == entity
            }
            if let index {
                contents.swapAt(index, contents.count - 1)
                return true
            }
            return false
        }
    }

    public var grid: [int4: Int] = [:]
    public var usedCells: [Cell<T>] = []
    public var populatedLevels: [Int: Int] = [:]

    public init(capacity: Int) {
        grid.reserveCapacity(capacity)
        populatedLevels.reserveCapacity(10)
    }

    public var CellCount: Int { return usedCells.count }

    public mutating func Clear() {
        grid = [:]
        usedCells = []
        populatedLevels = [:]
    }

    public func GetOrCreateCell(cellCoords _: int4) -> Int { 0 }

    public func TryGetCellIndex(cellCoords _: int4, cellIndex _: inout Int) -> Bool { false }

    public func RemoveEmpty() {}

    public static func GridLevelForSize(size _: Float) -> Int { 0 }

    public static func CellSizeOfLevel(level _: Int) -> Float { 0 }

    public static func GetParentCellCoords(cellCoords _: int4, level _: Int) -> int4 { int4() }

    public func RemoveFromCells(span _: BurstCellSpan, content _: T) {}

    public func AddToCells(span _: BurstCellSpan, content _: T) {}

    public static func GetCellCoordsForBoundsAtLevel(coords _: [int4], bounds _: BurstAabb,
                                                     level _: Int, maxSize _: Int = 10) {}

    private func IncreaseLevelPopulation(level _: Int) {}

    private func DecreaseLevelPopulation(level _: Int) {}
}
