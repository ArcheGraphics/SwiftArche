//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import Metal

/// Background of scene.
public class Background {
    /// Background mode.
    /// @defaultValue `BackgroundMode.SolidColor`
    /// - Remark: If using `BackgroundMode.Sky` mode and material or mesh of the `sky` is not defined, it will downgrade to `BackgroundMode.SolidColor`.
    public var mode: BackgroundMode = BackgroundMode.SolidColor

    /// Background solid color.
    /// @defaultValue `Color(0.25, 0.25, 0.25, 1.0)`
    /// - Remark: When `mode` is `BackgroundMode.SolidColor`, the property will take effects.
    public var solidColor: Color = Color(0.25, 0.25, 0.25, 1.0)

    /// Background sky.
    /// - Remark: When `mode` is `BackgroundMode.Sky`, the property will take effects.
    public var sky: SkySubpass?

    /// Background texture
    /// - Remark: When `mode` is `BackgroundMode.Texture`, the property will take effects.
    public var texture: BackgroundSubpass?

#if os(iOS)
    /// Background ar.
    /// - Remark: When `mode` is `BackgroundMode.AR`, the property will take effects.
    public var ar: ARSubpass?
#endif
}
