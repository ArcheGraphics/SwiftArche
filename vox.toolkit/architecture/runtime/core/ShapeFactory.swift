//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Describes the type of pivot ProBuilder would automatically assign on primitive creation.
public enum PivotLocation {
    case Center
    case FirstCorner
}

public class ShapeFactory {
    /// Create a shape with default parameters.
    /// - Parameters:
    ///   - shape: The ShapeType to create.
    ///   - pivotType: Where the shape's pivot will be.
    /// - Returns: A new GameObject with the ProBuilderMesh initialized to the primitive shape.
    // public static func Instantiate(shape: Shape, pivotType: PivotLocation = PivotLocation.Center) -> ProBuilderMesh {
    //
    // }
}
