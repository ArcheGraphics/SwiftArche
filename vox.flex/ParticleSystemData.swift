//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class ParticleSystemData: ShaderData {
    private static let positionProperty = "u_position"
    private static let velocityProperty = "u_velocity"
    private static let forceProperty = "u_force"
    private static let counterProperty = "u_counter"

    private var _radius: Float = 1e-3
    private var _mass: Float = 1e-3
    private var _maxLength: UInt32 = 0
    private var _neighborSearcher: HashGrid?
    
    public var neighborSearcher: HashGrid? {
        get {
            _neighborSearcher
        }
    }
    
    /// the radius of the particles.
    public var radius: Float {
        get {
            _radius
        }
        set {
            _radius = max(newValue, 0)
        }
    }
    
    /// the mass of the particles.
    public var mass: Float {
        get {
            _mass
        }
        set {
            _mass = max(newValue, 0)
        }
    }

    /// the  maxnumber of particles.
    public var maxNumberOfParticles: UInt32 {
        get {
            _maxLength
        }
    }
    
    /// the number of particles.
    public var numberOfParticles: BufferView {
        get {
            getData(ParticleSystemData.counterProperty)!
        }
    }
    
    /// the position array
    public var positions: BufferView {
        get {
            getData(ParticleSystemData.positionProperty)!
        }
    }
    
    /// the velocity array
    public var velocities: BufferView {
        get {
            getData(ParticleSystemData.velocityProperty)!
        }
    }
    
    ///  the force array
    public var forces: BufferView {
        get {
            getData(ParticleSystemData.forceProperty)!
        }
    }
    
    public init(_ engine: Engine, maxLength: UInt32) {
        super.init(engine)
        _maxLength = maxLength
        addScalarData(with: ParticleSystemData.counterProperty, initialVal: UInt32(0), maxLength: 1)
        addScalarData(with: ParticleSystemData.positionProperty, initialVal: Vector3F(), maxLength: Int(maxLength))
        addScalarData(with: ParticleSystemData.velocityProperty, initialVal: Vector3F(), maxLength: Int(maxLength))
        addScalarData(with: ParticleSystemData.forceProperty, initialVal: Vector3F(), maxLength: Int(maxLength))
    }
    
    /// Adds a data layer
    /// - Parameters:
    ///   - name: shader paramter name, used in reflection
    ///   - initialVal: Initial value of the new scalar data.
    ///   - maxLength: max length
    public func addScalarData<T>(with name: String, initialVal: T, maxLength: Int) {
        let data = BufferView(device: engine.device, count: maxLength, stride: MemoryLayout<T>.stride)
        data.assign(initialVal)
        setData(name, data)
    }
    
    //! Builds neighbor searcher with given search radius.
    public func buildNeighborSearcher(commandBuffer: MTLCommandBuffer, maxSearchRadius: Float, hashGridResolution: UInt32 = 64) {
        if _neighborSearcher == nil {
            _neighborSearcher = HashGrid(engine, hashGridResolution, hashGridResolution, hashGridResolution, maxSearchRadius * 2)
        }
        _neighborSearcher!.build(commandBuffer: commandBuffer, positions: positions,
                                 itemCount: numberOfParticles, maxNumberOfParticles: maxNumberOfParticles)
    }
}
