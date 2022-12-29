//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class SphSystemData: ParticleSystemData {
    private static let pressureProperty = "u_pressure"
    private static let densityProperty = "u_density"
    
    /// Target density of this particle system in kg/m^3.
    private var _targetDensity: Float = kWaterDensity
    /// Target spacing of this particle system in meters.
    private var _targetSpacing: Float = 0.1
    /// Relative radius of SPH kernel.
    /// SPH kernel radius divided by target spacing.
    private var _kernelRadiusOverTargetSpacing: Float = 1.8
    /// SPH kernel radius in meters.
    private var _kernelRadius: Float = 0
    
    /// the pressure array
    public var pressure: BufferView {
        get {
            getData(SphSystemData.pressureProperty)!
        }
    }
    
    ///  the density array
    public var density: BufferView {
        get {
            getData(SphSystemData.densityProperty)!
        }
    }
    
    public var targetDensity: Float {
        get {
            _targetDensity
        }
        set {
            _targetDensity = newValue
            computeMass()
        }
    }
    
    public var targetSpacing: Float {
        get {
            _targetSpacing
        }
        set {
            _targetSpacing = newValue
            _kernelRadius = _kernelRadiusOverTargetSpacing * _targetSpacing
            computeMass()
        }
    }
    
    public var relativeKernelRadius: Float {
        get {
            _kernelRadiusOverTargetSpacing
        }
        set {
            _kernelRadiusOverTargetSpacing = newValue
            _kernelRadius = _kernelRadiusOverTargetSpacing * _targetSpacing
            computeMass()
        }
    }
    
    public var kernelRadius: Float {
        get {
            _kernelRadius
        }
        set {
            _kernelRadius = newValue
            _targetSpacing = _kernelRadius / _kernelRadiusOverTargetSpacing
            computeMass()
        }
    }
    
    public override init(_ engine: Engine, maxLength: UInt32) {
        super.init(engine, maxLength: maxLength)
        addScalarData(with: SphSystemData.pressureProperty, initialVal: Float(0), maxLength: Int(maxLength))
        addScalarData(with: SphSystemData.densityProperty, initialVal: Float(0), maxLength: Int(maxLength))
        targetSpacing = _targetSpacing
    }
    
    public func computeMass() {
        var points: [Vector3F] = []
        let pointsGenerator = BccLatticePointGenerator()
        let sampleBound = BoundingBox3F(
            point1: Vector3F(-1.5 * _kernelRadius, -1.5 * _kernelRadius,
                              -1.5 * _kernelRadius),
            point2: Vector3F(1.5 * _kernelRadius, 1.5 * _kernelRadius,
                             1.5 * _kernelRadius))
        
        pointsGenerator.generate(boundingBox: sampleBound, spacing: _targetSpacing, points: &points)
        
        var maxNumberDensity: Float = 0.0
        let kernel = SphStdKernel3(kernelRadius: _kernelRadius)
        for point in points {
            var sum: Float = 0.0;
            
            for neighborPoint in points {
                sum += kernel[simd_distance(neighborPoint, point)]
            }
            maxNumberDensity = max(maxNumberDensity, sum);
        }
        _mass = _targetDensity / maxNumberDensity
    }
}
