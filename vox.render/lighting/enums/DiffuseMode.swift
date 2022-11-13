//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Diffuse mode.
public enum DiffuseMode {
    /// Solid color mode.
    case SolidColor

    /// SH mode
    /// - Remark:
    /// Use SH3 to represent irradiance environment maps efficiently,
    //// allowing for interactive rendering of diffuse objects under distant illumination.
    case SphericalHarmonics
}
