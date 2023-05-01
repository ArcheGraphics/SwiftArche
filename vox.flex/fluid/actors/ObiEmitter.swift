//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiEmitter: ObiActor {
    public enum EmissionMethod {
        /// Continously emits particles until there are no particles left to emit.
        case STREAM

        /// Emits a single burst of particles from the emitter, and does not emit any more until
        /// all alive particles have died.
        case BURST
    }

    public var emitterBlueprint: ObiEmitterBlueprintBase?

    /// <summary>
    /// The base actor blueprint used by this actor.
    /// </summary>
    /// This is the same as <see cref="emitterBlueprint"/>.
    public var sourceBlueprint: ObiActorBlueprint? { return emitterBlueprint }

    /// Filter used for collision detection.
    private var filter: Int = ObiUtils.MakeFilter(mask: ObiUtils.CollideWithEverything, category: 1)

    /// Emission method used by this emitter.
    public var emissionMethod = EmissionMethod.STREAM

    /// Minimum amount of inactive particles available before the emitter is allowed to resume emission.
    public var minPoolSize: Float = 0.5

    /// Speed (in meters/second) at which fluid is emitter.
    /// Note this affects both the speed and the amount of particles emitted per second, to ensure flow is as smooth as possible.
    /// Set it to zero to deactivate emission.
    public var speed: Float = 0.25

    /// Particle lifespan in seconds.
    /// Particles older than this value will become inactive and go back to the solver's emission pool, making them available for reuse.
    public var lifespan: Float = 4

    /// Amount of random velocity added to particles when emitted.
    public var randomVelocity: Float = 0

    /// Use the emitter shape color to tint particles upon emission.
    public var useShapeColor: Bool = true

    private var emitterShapes: [ObiEmitterShape] = []
    private var distEnumerator: [ObiEmitterShape.DistributionPoint] = []

    /// Per particle remaining life (in seconds).
    public var life: [Float] = []

    private var unemittedBursts: Float = 0
    private var m_IsEmitting = false

    /// Adds a shape trough which to emit particles. This is called automatically by <see cref="ObiEmitterShape"/>.
    public func AddShape(shape _: ObiEmitterShape) {}

    /// Removes a shape trough which to emit particles. This is called automatically by <see cref="ObiEmitterShape"/>.
    public func RemoveShape(shape _: ObiEmitterShape) {}

    /// Updates the spawn point distribution of all shapes used by this emitter.
    public func UpdateEmitterDistribution() {}

    private func GetDistributionEnumerator() {}

    public func UpdateParticleMaterial() {}

    public func SetSelfCollisions(selfCollisions _: Bool) {}

    private func UpdateFilter() {}

    private func UpdateParticleResolution(index _: Int) {}

    private func UpdateParticleMaterial(index _: Int) {}

    func SwapWithFirstInactiveParticle(actorIndex _: Int) {}

    private func ResetParticle(index _: Int, offset _: Float, deltaTime _: Float) {}

    /// Asks the emitter to emit a new particle. Returns whether the emission was succesful.
    /// - Parameters:
    ///   - offset: Distance from the emitter surface at which the particle should be emitted.
    ///   - deltaTime: Duration of the last step in seconds.
    /// - Returns: If at least one particle was in the emission pool and it could be emitted, will return true. False otherwise.
    public func EmitParticle(offset _: Float, deltaTime _: Float) -> Bool {
        false
    }

    /// Asks the emiter to kill a particle. Returns whether it was succesful.
    /// - Returns: True if the particle could be killed. False if it was already inactive.
    public func KillParticle(index _: Int) -> Bool {
        false
    }

    /// Kills all particles in the emitter, and returns them to the emission pool.
    public func KillAll() {}

    private func GetDistributionPointsCount() -> Int {
        0
    }

    public func BeginStep(stepTime _: Float) {}
}
