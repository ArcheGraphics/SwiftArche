//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Frustum face
public enum FrustumFace: Int {
    /// Near face
    case Near = 0
    /// Far face
    case Far = 1
    /// Left face
    case Left = 2
    /// Right face
    case Right = 3
    /// Bottom face
    case Bottom = 4
    /// Top face
    case Top = 5
}
