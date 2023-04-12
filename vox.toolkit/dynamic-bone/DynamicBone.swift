//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class DynamicBone: Script {
    /// The roots of the transform hierarchy to apply physics.
    public var m_Root: Transform?
    public var m_Roots: [Transform] = []

    /// Internal physics simulation rate.
    public var m_UpdateRate: Float = 60.0

    public enum UpdateMode {
        case Normal
        case AnimatePhysics
        case UnscaledTime
        case Default
    }

    public var m_UpdateMode = UpdateMode.Default

    /// How much the bones slowed down.
    public var m_Damping: Float = 0.1

    /// How much the force applied to return each bone to original orientation.
    public var m_Elasticity: Float = 0.1

    /// How much bone's original orientation are preserved.
    public var m_Stiffness: Float = 0.1

    /// How much character's position change is ignored in physics simulation.
    public var m_Inert: Float = 0

    /// How much the bones slowed down when collide.
    public var m_Friction: Float = 0

    /// Each bone can be a sphere to collide with colliders. Radius describe sphere's size.
    public var m_Radius: Float = 0

    /// If End Length is not zero, an extra bone is generated at the end of transform hierarchy.
    public var m_EndLength: Float = 0

    /// If End Offset is not zero, an extra bone is generated at the end of transform hierarchy.
    public var m_EndOffset = Vector3.zero

    /// The force apply to bones. Partial force apply to character's initial pose is cancelled out.
    public var m_Gravity = Vector3.zero

    /// The force apply to bones.
    public var m_Force = Vector3.zero

    /// Control how physics blends with existing animation.
    public var m_BlendWeight = 1.0

    /// Collider objects interact with the bones.
    public var m_Colliders: [DynamicBoneColliderBase] = []

    /// Bones exclude from physics simulation.
    public var m_Exclusions: [Transform] = []

    public enum FreezeAxis {
        case None, X, Y, Z
    }

    /// Constrain bones to move on specified plane.
    public var m_FreezeAxis = FreezeAxis.None

    /// Disable physics simulation automatically if character is far from camera or player.
    public var m_DistantDisable = false
    public var m_ReferenceObject: Transform?
    public var m_DistanceToObject: Float = 20

    public var m_Multithread = true

    var m_ObjectMove = Vector3()
    var m_ObjectPrevPosition = Vector3()
    var m_ObjectScale: Float = 0

    var m_Time: Float = 0
    var m_Weight: Float = 1.0
    var m_DistantDisabled = false
    var m_WorkAdded = false
    var m_PreUpdateCount: Int = 0

    class Particle {
        public var m_Transform: Transform?
        public var m_ParentIndex: Int = 0
        public var m_ChildCount: Int = 0
        public var m_Damping: Float = 0
        public var m_Elasticity: Float = 0
        public var m_Stiffness: Float = 0
        public var m_Inert: Float = 0
        public var m_Friction: Float = 0
        public var m_Radius: Float = 0
        public var m_BoneLength: Float = 0
        public var m_isCollide = false
        public var m_TransformNotNull = false

        public var m_Position = Vector3()
        public var m_PrevPosition = Vector3()
        public var m_EndOffset = Vector3()
        public var m_InitLocalPosition = Vector3()
        public var m_InitLocalRotation = Quaternion()

        // prepare data
        public var m_TransformPosition = Vector3()
        public var m_TransformLocalPosition = Vector3()
        public var m_TransformLocalToWorldMatrix = Matrix()
    }

    class ParticleTree {
        public var m_Root: Transform?
        public var m_LocalGravity = Vector3()
        public var m_RootWorldToLocalMatrix = Matrix()
        public var m_BoneTotalLength: Float = 0
        public var m_Particles: [Particle] = []

        // prepare data
        public var m_RestGravity = Vector3()
    }

    var m_ParticleTrees: [ParticleTree] = []

    // prepare data
    var m_DeltaTime: Float = 0
    var m_EffectiveColliders: [DynamicBoneColliderBase] = []

    override public func onPhysicsUpdate() {}

    override public func onUpdate(_: Float) {}

    override public func onLateUpdate(_: Float) {}

    func prepare() {}

    func isNeedUpdate() -> Bool {
        false
    }

    func preUpdate() {}

    func checkDistance() {}

    override public func onEnable() {}

    override public func onDisable() {}

    func isRootChanged() -> Bool {
        false
    }

    func onDidApplyAnimationProperties() {}

    public func setWeight(w _: Float) {}

    public func getWeight() -> Float {
        0
    }

    func updateParticles() {}

    public func setupParticles() {}

    func appendParticleTree(root _: Transform) {}

    func appendParticles(pt _: ParticleTree, b _: Transform, parentIndex _: Int, boneLength _: Float) {}

    public func updateParameters() {}

    func updateParameters(pt _: ParticleTree) {}

    func initTransforms() {}

    func initTransforms(pt _: ParticleTree) {}

    func resetParticlesPosition() {}

    func resetParticlesPosition(pt _: ParticleTree) {}

    func updateParticles1(timeVar _: Float, loopIndex _: Int) {}

    func updateParticles1(pt _: ParticleTree, timeVar _: Float, loopIndex _: Int) {}

    func updateParticles2(timeVar _: Float) {}

    func updateParticles2(pt _: ParticleTree, timeVar _: Float) {}

    func skipUpdateParticles() {}

    // only update stiffness and keep bone length
    func skipUpdateParticles(pt _: ParticleTree) {}

    static func mirrorVector(v _: Vector3, axis _: Vector3) -> Vector3 {
        Vector3()
    }

    func applyParticlesToTransforms() {}

    func applyParticlesToTransforms(pt _: ParticleTree, ax _: Vector3, ay _: Vector3, az _: Vector3,
                                    nx _: Bool, ny _: Bool, nz _: Bool) {}

    static func addPendingWork(db _: DynamicBone) {}

    static func addWorkToQueue(db _: DynamicBone) {}

    static func getWorkFromQueue() -> DynamicBone? {
        nil
    }

    static func threadProc() {}

    static func initThreadPool() {}

    static func executeWorks() {}
}
