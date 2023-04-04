//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Functions for picking mesh elements in a view. Can either render a texture to test, or cast a ray. Prefer this over calling SelectionPickerRenderer directly.
public enum SelectionPicker {
    /// Pick the vertex indexes contained within a rect.
    /// - Parameters:
    ///   - cam: cam
    ///   - rect: Rect is in GUI space, where 0,0 is top left of screen, width = cam.pixelWidth / pointsPerPixel.
    ///   - selectable: The objects to hit test.
    ///   - options: Culling options.
    ///   - pixelsPerPoint: Scale the render texture to match rect coordinates. Generally you'll just pass in EditorGUIUtility.pointsPerPixel.
    /// - Returns: A dictionary of ProBuilderMesh and sharedIndexes that are in the selection rect. To get triangle indexes access the pb.sharedIndexes[index] array.
    public static func PickVerticesInRect(cam _: Camera,
                                          rect _: Rect,
                                          selectable _: [ProBuilderMesh],
                                          options _: PickerOptions,
                                          pixelsPerPoint _: Float = 1) -> [ProBuilderMesh: Set<Int>]
    {
        [:]
    }
}
