//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Fog Mode.
public enum FogMode: Int {
  /// Disable fog.
  case None
  /// Linear fog.
  case Linear
  /// Exponential fog.
  case Exponential
  /// Exponential squared fog.
  case ExponentialSquared
}
