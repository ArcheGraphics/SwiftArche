//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import Math
import vox_render

/// A collection of settings describing how to project UV coordinates for a @"UnityEngine.ProBuilder.Face".
public struct AutoUnwrapSettings {
    public static var defaultAutoUnwrapSettings: AutoUnwrapSettings {
        var settings = AutoUnwrapSettings()
        settings.Reset()
        return settings
    }

    /// The point from which UV transform operations will be performed.
    /// After the initial projection into 2d space, UVs will be translated to the anchor position. Next, the offset and rotation are applied, followed by the various other settings.
    public enum Anchor {
        /// The top left bound of the projected UVs is aligned with UV coordinate {0, 1}.
        case UpperLeft
        /// The center top bound of the projected UVs is aligned with UV coordinate {.5, 1}.
        case UpperCenter
        /// The right top bound of the projected UVs is aligned with UV coordinate {1, 1}.
        case UpperRight
        /// The middle left bound of the projected UVs is aligned with UV coordinate {0, .5}.
        case MiddleLeft
        /// The center bounding point of the projected UVs is aligned with UV coordinate {.5, .5}.
        case MiddleCenter
        /// The middle right bound of the projected UVs is aligned with UV coordinate {1, .5}.
        case MiddleRight
        /// The lower left bound of the projected UVs is aligned with UV coordinate {0, 0}.
        case LowerLeft
        /// The lower center bound of the projected UVs is aligned with UV coordinate {.5, 0}.
        case LowerCenter
        /// The lower right bound of the projected UVs is aligned with UV coordinate {1, 0}.
        case LowerRight
        /// UVs are not aligned following projection.
        case None
    }

    /// Describes how the projected UV bounds are optionally stretched to fill normalized coordinate space.
    public enum Fill {
        /// UV bounds are resized to fit within a 1 unit square while retaining original aspect ratio.
        case Fit
        /// UV bounds are not resized.
        case Tile
        /// UV bounds are resized to fit within a 1 unit square, not retaining aspect ratio.
        case Stretch
    }

    var m_UseWorldSpace: Bool = false
    var m_FlipU: Bool = false
    var m_FlipV: Bool = false
    var m_SwapUV: Bool = false
    var m_Fill: Fill = .Fit
    var m_Scale = Vector2()
    var m_Offset = Vector2()
    var m_Rotation: Float = 0
    var m_Anchor: Anchor = .None

    /// By default, UVs are project in local (or model) coordinates. Enable useWorldSpace to transform vertex positions into world space for UV projection.
    public var useWorldSpace: Bool {
        get {
            m_UseWorldSpace
        }
        set {
            m_UseWorldSpace = newValue
        }
    }

    /// When enabled UV coordinates will be inverted horizontally.
    public var flipU: Bool {
        get {
            m_FlipU
        }
        set {
            m_FlipU = newValue
        }
    }

    /// When enabled UV coordinates will be inverted vertically.
    public var flipV: Bool {
        get {
            m_FlipV
        }
        set {
            m_FlipV = newValue
        }
    }

    /// When enabled the coordinates will have their U and V parameters exchanged.
    /// {U, V} becomes {V, U}
    public var swapUV: Bool {
        get {
            m_SwapUV
        }
        set {
            m_SwapUV = newValue
        }
    }

    /// The @"UnityEngine.ProBuilder.AutoUnwrapSettings.Fill" mode.
    public var fill: Fill {
        get {
            m_Fill
        }
        set {
            m_Fill = newValue
        }
    }

    /// Coordinates are multiplied by this value after projection and anchor settings.
    public var scale: Vector2 {
        get {
            m_Scale
        }
        set {
            m_Scale = newValue
        }
    }

    /// Added to UV coordinates after projection and anchor settings.
    public var offset: Vector2 {
        get {
            m_Offset
        }
        set {
            m_Offset = newValue
        }
    }

    /// An amount in degrees that UV coordinates are to be rotated clockwise.
    public var rotation: Float {
        get {
            m_Rotation
        }
        set {
            m_Rotation = newValue
        }
    }

    /// The starting point from which UV transform operations will be performed.
    public var anchor: Anchor {
        get {
            m_Anchor
        }
        set {
            m_Anchor = newValue
        }
    }

    /// Get a set of unwrap parameters that tiles UVs.
    public static var tile: AutoUnwrapSettings {
        var res = AutoUnwrapSettings()
        res.Reset()
        return res
    }

    /// Get a set of unwrap parameters that strectches the face texture to fill a normalized coordinate space, maintaining th aspect ratio.
    public static var fit: AutoUnwrapSettings {
        var res = AutoUnwrapSettings()
        res.Reset()
        res.fill = Fill.Fit
        return res
    }

    /// Get a set of unwrap parameters that strectches the face texture to fill a normalized coordinate space, disregarding the aspect ratio.
    public static var stretch: AutoUnwrapSettings {
        var res = AutoUnwrapSettings()
        res.Reset()
        res.fill = Fill.Stretch
        return res
    }

    /// Resets all parameters to default values.
    public mutating func Reset() {
        m_UseWorldSpace = false
        m_FlipU = false
        m_FlipV = false
        m_SwapUV = false
        m_Fill = Fill.Tile
        m_Scale = Vector2(1, 1)
        m_Offset = Vector2(0, 0)
        m_Rotation = 0
        m_Anchor = Anchor.None
    }
}

extension AutoUnwrapSettings: CustomStringConvertible {
    public var description: String {
        "Use World Space: \(useWorldSpace)\n" +
            "Flip U: \(flipU)\n" +
            "Flip V: \(flipV)\n" +
            "Swap UV: \(swapUV)\n" +
            "Fill Mode: \(fill)\n" +
            "Anchor: \(anchor)\n" +
            "Scale: \(scale)\n" +
            "Offset: \(offset)\n" +
            "Rotation: \(rotation)"
    }
}
