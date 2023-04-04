//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Body-centered lattice points generator.
///
/// http://en.wikipedia.org/wiki/Cubic_crystal_system
/// http://mathworld.wolfram.com/CubicClosePacking.html
class BccLatticePointGenerator: PointGenerator {
    /// Invokes \p callback function for each BCC-lattice points inside
    /// \p boundingBox.
    ///
    /// This function iterates every BCC-lattice points inside \p boundingBox
    /// where \p spacing is the size of the unit cell of BCC structure.
    func forEachPoint(boundingBox: BoundingBox3F,
                      spacing: Float,
                      callback: (Vector3F) -> Bool)
    {
        let halfSpacing = spacing / 2.0
        let boxWidth = boundingBox.width
        let boxHeight = boundingBox.height
        let boxDepth = boundingBox.depth

        var position = Vector3F()
        var hasOffset = false
        var shouldQuit = false
        var k = 0
        while Float(k) * halfSpacing <= boxDepth && !shouldQuit {
            position.z = Float(k) * halfSpacing + boundingBox.lowerCorner.z

            let offset = hasOffset ? halfSpacing : 0.0
            var j = 0
            while Float(j) * spacing + offset <= boxHeight && !shouldQuit {
                position.y = Float(j) * spacing + offset + boundingBox.lowerCorner.y
                var i = 0
                while Float(i) * spacing + offset <= boxWidth {
                    position.x = Float(i) * spacing + offset + boundingBox.lowerCorner.x
                    if !callback(position) {
                        shouldQuit = true
                        break
                    }

                    i += 1
                }

                j += 1
            }

            hasOffset = !hasOffset

            k += 1
        }
    }
}
