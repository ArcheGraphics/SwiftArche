//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class ParticleSystemData {
    private static let positionProperty = "u_position"
    private static let velocityProperty = "u_velocity"
    private static let forceProperty = "u_force"

    private var _engine: Engine
    private var _radius: Float = 1e-3
    private var _mass: Float = 1e-3
    private var _numberOfParticles: BufferView
    private var _dataList: [String: BufferView] = [:]
    
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
    
    /// the number of particles.
    public var numberOfParticles: Int {
        get {
            _numberOfParticles[0]
        }
    }
    
    /// the position array
    public var positions: BufferView {
        get {
            _dataList[ParticleSystemData.positionProperty]!
        }
    }
    
    /// the velocity array
    public var velocities: BufferView {
        get {
            _dataList[ParticleSystemData.velocityProperty]!
        }
    }
    
    ///  the force array
    public var forces: BufferView {
        get {
            _dataList[ParticleSystemData.forceProperty]!
        }
    }
    
    public init(_ engine: Engine, maxLength: Int = 10000) {
        _engine = engine
        _numberOfParticles = BufferView(device: _engine.device, count: 1, stride: MemoryLayout<UInt32>.stride)
        addScalarData(with: ParticleSystemData.positionProperty, initialVal: Vector3F(), maxLength: maxLength)
        addScalarData(with: ParticleSystemData.velocityProperty, initialVal: Vector3F(), maxLength: maxLength)
        addScalarData(with: ParticleSystemData.forceProperty, initialVal: Vector3F(), maxLength: maxLength)
    }
    
    /// Adds a data layer
    /// - Parameters:
    ///   - name: shader paramter name, used in reflection
    ///   - initialVal: Initial value of the new scalar data.
    ///   - maxLength: max length
    public func addScalarData<T>(with name: String, initialVal: T, maxLength: Int) {
        _dataList[name] = BufferView(device: _engine.device, count: maxLength, stride: MemoryLayout<T>.stride)
    }
    
    /// Returns custom scalar data layer at given name
    public func data(at name: String) -> BufferView? {
        _dataList[name]
    }
}
