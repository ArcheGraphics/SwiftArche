//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public final class PCISphSolver: WCSphSolver {
    static let kDefaultTimeStepLimitScale: Float = 5.0
    
    private var _maxDensityErrorRatio: Float = 0.01
    private var _maxNumberOfIterations: UInt = 5
    
    public var maxDensityErrorRatio: Float {
        get {
            _maxDensityErrorRatio
        }
        set {
            _maxDensityErrorRatio = max(newValue, 0)
        }
    }
    
    public var maxNumberOfIterations: UInt {
        get {
            _maxNumberOfIterations
        }
        set {
            _maxNumberOfIterations = newValue
        }
    }
    
    public required init(_ engine: Engine) {
        super.init(engine)
        let sph = SphSystemData(engine, maxLength: ParticleSystemSolverBase.maxLength)
        sph.targetDensity = kWaterDensity
        sph.targetSpacing = 0.1
        sph.relativeKernelRadius = 1.8
        _particleSystemData = sph
        
        timeStepLimitScale = PCISphSolver.kDefaultTimeStepLimitScale
        sph.addScalarData(with: "u_tempPositions", initialVal: Vector3F(), maxLength: Int(ParticleSystemSolverBase.maxLength))
        sph.addScalarData(with: "u_tempVelocities", initialVal: Vector3F(), maxLength: Int(ParticleSystemSolverBase.maxLength))
        sph.addScalarData(with: "u_tempDensities", initialVal: Float(0), maxLength: Int(ParticleSystemSolverBase.maxLength))
        sph.addScalarData(with: "u_pressureForces", initialVal: Vector3F(), maxLength: Int(ParticleSystemSolverBase.maxLength))
        sph.addScalarData(with: "u_densityErrors", initialVal: Float(0), maxLength: Int(ParticleSystemSolverBase.maxLength))
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func computeDelta(_ timeStepInSeconds: Float)-> Float {
        if let sphSystemData = sphSystemData {
            let kernelRadius = sphSystemData.kernelRadius
            
            var points: [Vector3F] = []
            let pointsGenerator = BccLatticePointGenerator()
            let origin = Vector3F()
            var sampleBound = BoundingBox3F(point1: origin, point2: origin)
            sampleBound.expand(delta: 1.5 * kernelRadius)
            
            pointsGenerator.generate(boundingBox: sampleBound, spacing: sphSystemData.targetSpacing, points: &points)
            
            let kernel = SphSpikyKernel3(kernelRadius: kernelRadius)
            
            var denom: Float = 0
            var denom1 = Vector3F()
            var denom2: Float = 0
            
            for point in points {
                let distanceSquared = length_squared(point)
                
                if (distanceSquared < kernelRadius * kernelRadius) {
                    let distance = sqrt(distanceSquared)
                    let direction = (distance > 0.0) ? point / distance : Vector3F()
                    
                    // grad(Wij)
                    let gradWij = kernel.gradient(distance: distance, direction: direction)
                    denom1 += gradWij
                    denom2 += simd_length_squared(gradWij)
                }
            }
            
            denom += -simd_length_squared(denom1) - denom2
            let beta = computeBeta(timeStepInSeconds)
            
            return Float((abs(denom) > 0.0) ? -1 / (beta * denom) : 0)
        } else {
            return 0
        }
    }
    
    func computeBeta(_ timeStepInSeconds: Float) -> Float {
        return 2.0 * Math.square(of: sphSystemData!.mass * timeStepInSeconds / sphSystemData!.targetDensity)
    }
    
    override func accumulatePressureForce(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {}
}
