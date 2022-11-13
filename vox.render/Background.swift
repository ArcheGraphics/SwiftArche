//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Background of scene.
public class Background {
    /// Background mode.
    /// @defaultValue `BackgroundMode.SolidColor`
    /// @remarks If using `BackgroundMode.Sky` mode and material or mesh of the `sky` is not defined, it will downgrade to `BackgroundMode.SolidColor`.
    public var mode: BackgroundMode = BackgroundMode.SolidColor;

    /// Background solid color.
    /// @defaultValue `Color(0.25, 0.25, 0.25, 1.0)`
    /// @remarks When `mode` is `BackgroundMode.SolidColor`, the property will take effects.
    public var solidColor: Color = Color(0.25, 0.25, 0.25, 1.0);
}