//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public extension MTLRegion {
    var minX: Int {
        origin.x
    }

    var minY: Int {
        origin.y
    }

    var minZ: Int {
        origin.z
    }

    var maxX: Int {
        origin.x + size.width - 1
    }

    var maxY: Int {
        origin.y + size.height - 1
    }

    var maxZ: Int {
        origin.z + size.depth - 1
    }

    var area: Int {
        size.width * size.height
    }

    func clamped(to region: MTLRegion) -> MTLRegion? {
        let ox = max(origin.x, region.origin.x)
        let oy = max(origin.y, region.origin.y)
        let oz = max(origin.z, region.origin.z)

        let maxX = min(maxX, region.maxX)
        let maxY = min(maxY, region.maxY)
        let maxZ = min(maxZ, region.maxZ)

        guard ox < maxX, oy < maxY, oz < maxZ
        else {
            return nil
        }

        return MTLRegion(origin: .init(x: ox,
                                       y: oy,
                                       z: oz),
                         size: .init(width: maxX - ox + 1,
                                     height: maxY - oy + 1,
                                     depth: maxZ - oz + 1))
    }

    static func == (lhs: MTLRegion, rhs: MTLRegion) -> Bool {
        lhs.origin == rhs.origin
            && lhs.size == rhs.size
    }
}
