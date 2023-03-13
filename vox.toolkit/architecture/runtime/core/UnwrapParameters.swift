//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Store UV2 unwrapping parameters.
public final class UnwrapParameters {
    internal static let k_HardAngle: Float = 88
    internal static let k_PackMargin: Float = 20
    internal static let k_AngleError: Float = 8
    internal static let k_AreaError: Float = 15

    /// Angle between neighbor triangles that will generate seam.
    var m_HardAngle: Float = UnwrapParameters.k_HardAngle

    /// Measured in pixels, assuming mesh will cover an entire 1024x1024 lightmap.
    var m_PackMargin: Float = UnwrapParameters.k_PackMargin

    /// Measured in percents. Angle error measures deviation of UV angles from geometry angles. Area error
    /// measures deviation of UV triangles area from geometry triangles if they were uniformly scaled.
    var m_AngleError: Float = UnwrapParameters.k_AngleError

    /// areaError
    var m_AreaError: Float = UnwrapParameters.k_AreaError

    /// Angle between neighbor triangles that will generate seam.
    public var hardAngle: Float {
        get {
            m_HardAngle
        }
        set {
            m_HardAngle = newValue
        }
    }

    /// Measured in pixels, assuming mesh will cover an entire 1024x1024 lightmap.
    public var packMargin: Float {
        get {
            m_PackMargin
        }
        set {
            m_PackMargin = newValue
        }
    }

    /// Measured in percents. Angle error measures deviation of UV angles from geometry angles. Area error measures
    /// deviation of UV triangles area from geometry triangles if they were uniformly scaled.
    public var angleError: Float {
        get {
            m_AngleError
        }
        set {
            m_AngleError = newValue
        }
    }

    /// Does... something.
    public var areaError: Float {
        get {
            m_AreaError
        }
        set {
            m_AreaError = newValue
        }
    }

    public init() {
        Reset()
    }

    /// Copy constructor.
    /// - Parameter other: The UnwrapParameters to copy properties from.
    public init(other: UnwrapParameters) {
    }

    /// <summary>
    /// Reset the unwrap parameters to default values.
    /// </summary>
    public func Reset() {
    }
}
