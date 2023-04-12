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
    public var m_BlendWeight: Float = 1.0

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

    var m_ObjectMove = Vector3()
    var m_ObjectPrevPosition = Vector3()
    var m_ObjectScale: Float = 0

    var m_Time: Float = 0
    var m_Weight: Float = 1.0
    var m_DistantDisabled = false
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

    static var s_UpdateCount: Int = 0
    static var s_PrepareFrame: Int = 0

    override public func onPhysicsUpdate() {
        if m_UpdateMode == UpdateMode.AnimatePhysics {
            preUpdate()
        }
    }

    override public func onUpdate(_: Float) {
        if m_UpdateMode != UpdateMode.AnimatePhysics {
            preUpdate()
        }
        DynamicBone.s_UpdateCount += 1
    }

    override public func onLateUpdate(_: Float) {
        if m_PreUpdateCount == 0 {
            return
        }

        if DynamicBone.s_UpdateCount > 0 {
            DynamicBone.s_UpdateCount = 0
            DynamicBone.s_PrepareFrame += 1
        }

        setWeight(w: m_BlendWeight)

        checkDistance()
        if isNeedUpdate() {
            prepare()
            updateParticles()
            applyParticlesToTransforms()
        }
        m_PreUpdateCount = 0
    }

    func prepare() {
        m_DeltaTime = Time.deltaTime

        let transform = entity.transform!
        m_ObjectScale = abs(transform.lossyWorldScale.x)
        m_ObjectMove = transform.worldPosition - m_ObjectPrevPosition
        m_ObjectPrevPosition = transform.worldPosition

        for i in 0 ..< m_ParticleTrees.count {
            let pt = m_ParticleTrees[i]
            pt.m_RestGravity = Vector3.transformToVec3(v: pt.m_LocalGravity, m: pt.m_Root!.worldMatrix)

            for j in 0 ..< pt.m_Particles.count {
                let p = pt.m_Particles[j]
                if let transform = p.m_Transform {
                    p.m_TransformPosition = transform.position
                    p.m_TransformLocalPosition = transform.position
                    p.m_TransformLocalToWorldMatrix = transform.worldMatrix
                }
            }
        }

        m_EffectiveColliders = []

        for i in 0 ..< m_Colliders.count {
            let c = m_Colliders[i]
            if c.enabled {
                m_EffectiveColliders = []
                m_EffectiveColliders.append(c)

                if c.PrepareFrame != DynamicBone.s_PrepareFrame // colliders used by many dynamic bones only prepares once
                {
                    c.prepare()
                    c.PrepareFrame = DynamicBone.s_PrepareFrame
                }
            }
        }
    }

    func isNeedUpdate() -> Bool {
        return m_Weight > 0 && !(m_DistantDisable && m_DistantDisabled)
    }

    func preUpdate() {
        if isNeedUpdate() {
            initTransforms()
        }
        m_PreUpdateCount += 1
    }

    func checkDistance() {
        if !m_DistantDisable {
            return
        }

        if let rt = m_ReferenceObject {
            let d2 = (rt.worldPosition - entity.transform.worldPosition).lengthSquared()
            let disable = d2 > m_DistanceToObject * m_DistanceToObject
            if disable != m_DistantDisabled {
                if !disable {
                    resetParticlesPosition()
                }
                m_DistantDisabled = disable
            }
        }
    }

    override public func onEnable() {
        resetParticlesPosition()
    }

    override public func onDisable() {
        initTransforms()
    }

    func isRootChanged() -> Bool {
        var roots: [Transform] = []
        if let m_Root {
            roots.append(m_Root)
        }

        if !m_Roots.isEmpty {
            for root in m_Roots {
                if !roots.contains(root) {
                    roots.append(root)
                }
            }
        }

        if roots.count != m_ParticleTrees.count {
            return true
        }

        for i in 0 ..< roots.count {
            if roots[i] != m_ParticleTrees[i].m_Root {
                return true
            }
        }

        return false
    }

    func onDidApplyAnimationProperties() {
        updateParameters()
    }

    public func setWeight(w: Float) {
        if m_Weight != w {
            if w == 0 {
                initTransforms()
            } else if m_Weight == 0 {
                resetParticlesPosition()
            }
            m_Weight = w
            m_BlendWeight = w
        }
    }

    public func getWeight() -> Float {
        m_Weight
    }

    func updateParticles() {
        if m_ParticleTrees.count <= 0 {
            return
        }

        var loop = 1
        var timeVar: Float = 1
        let dt = m_DeltaTime

        if m_UpdateMode == UpdateMode.Default {
            if m_UpdateRate > 0 {
                timeVar = dt * m_UpdateRate
            }
        } else {
            if m_UpdateRate > 0 {
                let frameTime = 1.0 / m_UpdateRate
                m_Time += dt
                loop = 0

                while m_Time >= frameTime {
                    m_Time -= frameTime
                    loop += 1
                    if loop >= 3 {
                        m_Time = 0
                        break
                    }
                }
            }
        }

        if loop > 0 {
            for i in 0 ..< loop {
                updateParticles1(timeVar: timeVar, loopIndex: i)
                updateParticles2(timeVar: timeVar)
            }
        } else {
            skipUpdateParticles()
        }
    }

    public func setupParticles() {
        m_ParticleTrees = []

        if let m_Root {
            appendParticleTree(root: m_Root)
        }

        if !m_Roots.isEmpty {
            for i in 0 ..< m_Roots.count {
                let root = m_Roots[i]
                if m_ParticleTrees.contains(where: { x in
                    x.m_Root === root
                }) {
                    continue
                }

                appendParticleTree(root: root)
            }
        }

        let transform = entity.transform!
        m_ObjectScale = abs(transform.lossyWorldScale.x)
        m_ObjectPrevPosition = transform.worldPosition
        m_ObjectMove = Vector3.zero

        for i in 0 ..< m_ParticleTrees.count {
            let pt = m_ParticleTrees[i]
            appendParticles(pt: pt, b: pt.m_Root!, parentIndex: -1, boneLength: 0)
        }

        updateParameters()
    }

    func appendParticleTree(root: Transform) {
        let pt = ParticleTree()
        pt.m_Root = root
        pt.m_RootWorldToLocalMatrix = root.worldMatrix.invert()
        m_ParticleTrees.append(pt)
    }

    func appendParticles(pt: ParticleTree, b: Transform?, parentIndex: Int, boneLength: Float) {
        var boneLength = boneLength
        let p = Particle()
        p.m_Transform = b
        p.m_ParentIndex = parentIndex

        if let b {
            p.m_Position = b.worldPosition
            p.m_PrevPosition = b.worldPosition
            p.m_InitLocalPosition = b.position
            p.m_InitLocalRotation = b.rotationQuaternion
        }
        else // end bone
        {
            let pb = pt.m_Particles[parentIndex].m_Transform!
            if m_EndLength > 0 {
                let ppb = pb.entity.parent
                if let ppb {
                    p.m_EndOffset = Vector3.transformCoordinate(v: pb.worldPosition * 2 - ppb.transform.worldPosition,
                                                                m: pb.worldMatrix.invert()) * m_EndLength
                } else {
                    p.m_EndOffset = Vector3(m_EndLength, 0, 0)
                }
            } else {
                var offset = Vector3.transformToVec3(v: m_EndOffset, m: entity.transform.worldMatrix)
                offset += pb.worldPosition
                p.m_EndOffset = Vector3.transformCoordinate(v: offset, m: pb.worldMatrix.invert())
            }
            let offset = Vector3.transformCoordinate(v: p.m_EndOffset, m: pb.worldMatrix)
            p.m_Position = offset
            p.m_PrevPosition = offset
            p.m_InitLocalPosition = Vector3.zero
            p.m_InitLocalRotation = Quaternion()
        }

        if parentIndex >= 0 {
            boneLength += (pt.m_Particles[parentIndex].m_Transform!.worldPosition - p.m_Position).length()
            p.m_BoneLength = boneLength
            pt.m_BoneTotalLength = max(pt.m_BoneTotalLength, boneLength)
            pt.m_Particles[parentIndex].m_ChildCount += 1
        }

        let index = pt.m_Particles.count
        pt.m_Particles.append(p)

        if let b {
            for i in 0 ..< b.entity.childCount {
                let child = b.entity.children[i]
                var exclude = false
                if !m_Exclusions.isEmpty {
                    exclude = m_Exclusions.contains(child.transform)
                }
                if !exclude {
                    appendParticles(pt: pt, b: child.transform, parentIndex: index, boneLength: boneLength)
                } else if m_EndLength > 0 || m_EndOffset != Vector3.zero {
                    appendParticles(pt: pt, b: nil, parentIndex: index, boneLength: boneLength)
                }
            }

            if b.entity.childCount == 0 && (m_EndLength > 0 || m_EndOffset != Vector3.zero) {
                appendParticles(pt: pt, b: nil, parentIndex: index, boneLength: boneLength)
            }
        }
    }

    public func updateParameters() {
        setWeight(w: m_BlendWeight)

        for i in 0 ..< m_ParticleTrees.count {
            updateParameters(pt: m_ParticleTrees[i])
        }
    }

    func updateParameters(pt: ParticleTree) {
        pt.m_LocalGravity = Vector3.transformToVec3(v: m_Gravity, m: pt.m_RootWorldToLocalMatrix)

        for i in 0 ..< pt.m_Particles.count {
            let p = pt.m_Particles[i]
            p.m_Damping = m_Damping
            p.m_Elasticity = m_Elasticity
            p.m_Stiffness = m_Stiffness
            p.m_Inert = m_Inert
            p.m_Friction = m_Friction
            p.m_Radius = m_Radius

            p.m_Damping = MathUtil.clamp01(value: p.m_Damping)
            p.m_Elasticity = MathUtil.clamp01(value: p.m_Elasticity)
            p.m_Stiffness = MathUtil.clamp01(value: p.m_Stiffness)
            p.m_Inert = MathUtil.clamp01(value: p.m_Inert)
            p.m_Friction = MathUtil.clamp01(value: p.m_Friction)
            p.m_Radius = max(p.m_Radius, 0)
        }
    }

    func initTransforms() {
        for i in 0 ..< m_ParticleTrees.count {
            initTransforms(pt: m_ParticleTrees[i])
        }
    }

    func initTransforms(pt: ParticleTree) {
        for i in 0 ..< pt.m_Particles.count {
            let p = pt.m_Particles[i]
            if let transform = p.m_Transform {
                transform.position = p.m_InitLocalPosition
                transform.rotationQuaternion = p.m_InitLocalRotation
            }
        }
    }

    func resetParticlesPosition() {
        for i in 0 ..< m_ParticleTrees.count {
            resetParticlesPosition(pt: m_ParticleTrees[i])
        }

        m_ObjectPrevPosition = entity.transform.worldPosition
    }

    func resetParticlesPosition(pt: ParticleTree) {
        for i in 0 ..< pt.m_Particles.count {
            let p = pt.m_Particles[i]
            if let transform = p.m_Transform {
                p.m_Position = transform.worldPosition
                p.m_PrevPosition = transform.worldPosition
            }
            else // end bone
            {
                let pb = pt.m_Particles[p.m_ParentIndex].m_Transform
                let newPosition = Vector3.transformCoordinate(v: p.m_EndOffset, m: pb!.worldMatrix)
                p.m_Position = newPosition
                p.m_PrevPosition = newPosition
            }
            p.m_isCollide = false
        }
    }

    func updateParticles1(timeVar: Float, loopIndex: Int) {
        for i in 0 ..< m_ParticleTrees.count {
            updateParticles1(pt: m_ParticleTrees[i], timeVar: timeVar, loopIndex: loopIndex)
        }
    }

    func updateParticles1(pt _: ParticleTree, timeVar _: Float, loopIndex _: Int) {}

    func updateParticles2(timeVar: Float) {
        for i in 0 ..< m_ParticleTrees.count {
            updateParticles2(pt: m_ParticleTrees[i], timeVar: timeVar)
        }
    }

    func updateParticles2(pt _: ParticleTree, timeVar _: Float) {}

    func skipUpdateParticles() {
        for i in 0 ..< m_ParticleTrees.count {
            skipUpdateParticles(pt: m_ParticleTrees[i])
        }
    }

    // only update stiffness and keep bone length
    func skipUpdateParticles(pt _: ParticleTree) {}

    func applyParticlesToTransforms() {
        var ax = Vector3.right
        var ay = Vector3.up
        var az = Vector3.forward
        var nx = false, ny = false, nz = false

        // detect negative scale
        let lossyScale = entity.transform.lossyWorldScale
        if lossyScale.x < 0 || lossyScale.y < 0 || lossyScale.z < 0 {
            var mirrorObject = entity.transform
            repeat {
                let ls = mirrorObject!.scale
                nx = ls.x < 0
                if nx {
                    ax = mirrorObject!.worldRight
                }
                ny = ls.y < 0
                if ny {
                    ay = mirrorObject!.worldUp
                }
                nz = ls.z < 0
                if nz {
                    az = mirrorObject!.worldForward
                }
                if nx || ny || nz {
                    break
                }

                mirrorObject = mirrorObject!.entity.parent?.transform
            } while mirrorObject != nil
        }

        for i in 0 ..< m_ParticleTrees.count {
            applyParticlesToTransforms(pt: m_ParticleTrees[i], ax: ax, ay: ay, az: az, nx: nx, ny: ny, nz: nz)
        }
    }

    func applyParticlesToTransforms(pt _: ParticleTree, ax _: Vector3, ay _: Vector3, az _: Vector3,
                                    nx _: Bool, ny _: Bool, nz _: Bool) {}

    static func mirrorVector(v: Vector3, axis: Vector3) -> Vector3 {
        return v - axis * (Vector3.dot(left: v, right: axis) * 2)
    }
}
