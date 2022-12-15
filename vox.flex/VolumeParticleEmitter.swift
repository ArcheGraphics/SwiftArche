//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class VolumeParticleEmitter: ParticleEmitter {
    private var _jitter: Float = 0

    public var implicitSurface: ImplicitTriangleMesh?
    public var maxRegionLower = Vector3F()
    public var maxRegionUpper = Vector3F()
    public var isOneShot: Bool = false
    public var allowOverlapping: Bool = false
    public var maxNumberOfParticles: Int = 0
    public var spacing: Float = 0
    public var initialVelocity = Vector3F()
    public var linearVelocity = Vector3F()
    public var angularVelocity = Vector3F()
    public var jitter: Float {
        get {
            _jitter
        }
        set {
            _jitter = simd_clamp(newValue, 0.0, 1.0)
        }
    }

    public override func update(currentTimeInSeconds: Float, timeIntervalInSeconds: Float) {

    }
}
