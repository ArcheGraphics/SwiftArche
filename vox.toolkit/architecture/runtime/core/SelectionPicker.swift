//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Functions for picking mesh elements in a view. Can either render a texture to test, or cast a ray. Prefer this over calling SelectionPickerRenderer directly.
public class SelectionPicker {
    /// Pick the vertex indexes contained within a rect.
    /// - Parameters:
    ///   - cam: cam
    ///   - rect: Rect is in GUI space, where 0,0 is top left of screen, width = cam.pixelWidth / pointsPerPixel.
    ///   - selectable: The objects to hit test.
    ///   - options: Culling options.
    ///   - pixelsPerPoint: Scale the render texture to match rect coordinates. Generally you'll just pass in EditorGUIUtility.pointsPerPixel.
    /// - Returns: A dictionary of ProBuilderMesh and sharedIndexes that are in the selection rect. To get triangle indexes access the pb.sharedIndexes[index] array.
    public static func PickVerticesInRect(cam: Camera,
                                          rect: Rect,
                                          selectable: [ProBuilderMesh],
                                          options: PickerOptions,
                                          pixelsPerPoint: Float = 1) -> Dictionary<ProBuilderMesh, Set<Int>> {
        [:]
    }
}
