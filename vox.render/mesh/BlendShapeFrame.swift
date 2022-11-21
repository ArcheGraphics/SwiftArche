//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// BlendShapeFrame.
public class BlendShapeFrame {
    /// Weight of BlendShapeFrame.
    var weight: Float
    /// Delta positions for the frame being added.
    var deltaPositions: [Vector3]
    /// Delta normals for the frame being added.
    var deltaNormals: [Vector3]?
    /// Delta tangents for the frame being added.
    var deltaTangents: [Vector3]?

    /// Create a BlendShapeFrame.
    /// - Parameters:
    ///   - weight: Weight of BlendShapeFrame
    ///   - deltaPositions: Delta positions for the frame being added
    ///   - deltaNormals: Delta normals for the frame being added
    ///   - deltaTangents: Delta tangents for the frame being added
    init(_ weight: Float,
         _ deltaPositions: [Vector3],
         _ deltaNormals: [Vector3]? = nil,
         _ deltaTangents: [Vector3]? = nil) {
        if (deltaNormals != nil && deltaNormals!.count != deltaPositions.count) {
            fatalError("deltaNormals length must same with deltaPositions length.")
        }

        if (deltaTangents != nil && deltaTangents!.count != deltaPositions.count) {
            fatalError("deltaTangents length must same with deltaPositions length.")
        }

        self.weight = weight
        self.deltaPositions = deltaPositions
        self.deltaNormals = deltaNormals
        self.deltaTangents = deltaTangents
    }
}
