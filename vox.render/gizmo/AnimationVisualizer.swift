//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class AnimationVisualizer: Script {
    var animator: Animator?
    let kInter: Float = 0.2
    var bones: [Gizmos.VertexPNC] = []
    var joints: [Gizmos.VertexPNC] = []
    var _skeletonData = [Float](repeating: 0, count: Int(CAnimator.kMaxJoints() * 64))

    public override func onAwake() {
        animator = entity.getComponent(Animator.self)
        _createBoneMesh()
        _createJointMesh()
    }

    public override func onGUI() {
        if let animator {
            let instanceCount = animator.fillPostureUniforms(&_skeletonData)
            let modelMat = entity.transform.worldMatrix
            for i in 0..<instanceCount {
                let col0 = SIMD4<Float>(_skeletonData[i * 16], _skeletonData[i * 16 + 1],
                        _skeletonData[i * 16 + 2], _skeletonData[i * 16 + 3])
                let col1 = SIMD4<Float>(_skeletonData[i * 16 + 4], _skeletonData[i * 16 + 5],
                        _skeletonData[i * 16 + 6], _skeletonData[i * 16 + 7])
                let col2 = SIMD4<Float>(_skeletonData[i * 16 + 8], _skeletonData[i * 16 + 9],
                        _skeletonData[i * 16 + 10], _skeletonData[i * 16 + 11])
                let col3 = SIMD4<Float>(_skeletonData[i * 16 + 12], _skeletonData[i * 16 + 13],
                        _skeletonData[i * 16 + 14], _skeletonData[i * 16 + 15])
                for j in 0..<bones.count / 3 {
                    let bone0 = bones[j * 3]
                    let bone1 = bones[j * 3 + 1]
                    let bone2 = bones[j * 3 + 2]
                    let instanceMat = _getBoneWorldMatrix(col0, col1, col2, col3)
                    let matrix = modelMat * instanceMat.modelMat
                    Gizmos.addTriangle(p0: Vector3.transformCoordinate(v: bone0.pos, m: matrix),
                                       p1: Vector3.transformCoordinate(v: bone1.pos, m: matrix),
                                       p2: Vector3.transformCoordinate(v: bone2.pos, m: matrix),
                                       n0: Vector3.transformNormal(v: bone0.normal, m: instanceMat.normalMat),
                                       n1: Vector3.transformNormal(v: bone1.normal, m: instanceMat.normalMat),
                                       n2: Vector3.transformNormal(v: bone2.normal, m: instanceMat.normalMat),
                                       color0: bone0.color, color1: bone1.color, color2: bone2.color)
                }
                for j in 0..<joints.count / 3 {
                    let joint0 = joints[j * 3]
                    let joint1 = joints[j * 3 + 1]
                    let joint2 = joints[j * 3 + 2]
                    let instanceMat = _getJointWorldMatrix(col0, col1, col2, col3)
                    let matrix = modelMat * instanceMat.modelMat
                    Gizmos.addTriangle(p0: Vector3.transformCoordinate(v: joint0.pos, m: matrix),
                                       p1: Vector3.transformCoordinate(v: joint1.pos, m: matrix),
                                       p2: Vector3.transformCoordinate(v: joint2.pos, m: matrix),
                                       n0: Vector3.transformNormal(v: joint0.normal, m: instanceMat.normalMat),
                                       n1: Vector3.transformNormal(v: joint1.normal, m: instanceMat.normalMat),
                                       n2: Vector3.transformNormal(v: joint2.normal, m: instanceMat.normalMat),
                                       color0: joint0.color, color1: joint1.color, color2: joint2.color)
                }
            }
        }
    }

    private func _createBoneMesh() {
        let pos: [Vector3] = [Vector3(1.0, 0.0, 0.0), Vector3(kInter, 0.1, 0.1), Vector3(kInter, 0.1, -0.1),
                              Vector3(kInter, -0.1, -0.1), Vector3(kInter, -0.1, 0.1), Vector3(0.0, 0.0, 0.0)]
        let normals: [Vector3] = [
            (pos[2] - pos[1]).cross(pos[2] - pos[0]).normalized,
            (pos[1] - pos[2]).cross(pos[1] - pos[5]).normalized,
            (pos[3] - pos[2]).cross(pos[3] - pos[0]).normalized,
            (pos[2] - pos[3]).cross(pos[2] - pos[5]).normalized,
            (pos[4] - pos[3]).cross(pos[4] - pos[0]).normalized,
            (pos[3] - pos[4]).cross(pos[3] - pos[5]).normalized,
            (pos[1] - pos[4]).cross(pos[1] - pos[0]).normalized,
            (pos[4] - pos[1]).cross(pos[4] - pos[5]).normalized,
        ]

        let white = Color32(r: 255, g: 255, b: 255)

        bones = [Gizmos.VertexPNC(pos[0], normals[0], white),
                 Gizmos.VertexPNC(pos[2], normals[0], white),
                 Gizmos.VertexPNC(pos[1], normals[0], white),

                 Gizmos.VertexPNC(pos[5], normals[1], white),
                 Gizmos.VertexPNC(pos[1], normals[1], white),
                 Gizmos.VertexPNC(pos[2], normals[1], white),

                 Gizmos.VertexPNC(pos[0], normals[2], white),
                 Gizmos.VertexPNC(pos[3], normals[2], white),
                 Gizmos.VertexPNC(pos[2], normals[2], white),

                 Gizmos.VertexPNC(pos[5], normals[3], white),
                 Gizmos.VertexPNC(pos[2], normals[3], white),
                 Gizmos.VertexPNC(pos[3], normals[3], white),

                 Gizmos.VertexPNC(pos[0], normals[4], white),
                 Gizmos.VertexPNC(pos[4], normals[4], white),
                 Gizmos.VertexPNC(pos[3], normals[4], white),

                 Gizmos.VertexPNC(pos[5], normals[5], white),
                 Gizmos.VertexPNC(pos[3], normals[5], white),
                 Gizmos.VertexPNC(pos[4], normals[5], white),

                 Gizmos.VertexPNC(pos[0], normals[6], white),
                 Gizmos.VertexPNC(pos[1], normals[6], white),
                 Gizmos.VertexPNC(pos[4], normals[6], white),

                 Gizmos.VertexPNC(pos[5], normals[7], white),
                 Gizmos.VertexPNC(pos[4], normals[7], white),
                 Gizmos.VertexPNC(pos[1], normals[7], white)
        ]
    }

    func _getBoneWorldMatrix(_ joint0: SIMD4<Float>, _ joint1: SIMD4<Float>,
                             _ joint2: SIMD4<Float>, _ joint3: SIMD4<Float>) -> (modelMat: Matrix, normalMat: Matrix3x3) {
        // Rebuilds bone properties.
        // Bone length is set to zero to disable leaf rendering.
        let is_bone = joint3.w
        let bone_dir = SIMD3<Float>(joint0.w, joint1.w, joint2.w) * is_bone
        let bone_len = length(bone_dir)

        // Setup rendering world matrix.
        let dot1 = dot(joint2.xyz, bone_dir)
        let dot2 = dot(joint0.xyz, bone_dir)
        let binormal = abs(dot1) < abs(dot2) ? joint2.xyz : joint0.xyz

        var world_matrix = simd_float4x4()
        world_matrix.columns.0 = SIMD4<Float>(bone_dir, 0.0)
        
        var boneTangent = cross(binormal, bone_dir)
        if length_squared(boneTangent) < Float.leastNonzeroMagnitude {
            world_matrix.columns.1 = SIMD4<Float>(0, 0, 0, 0)
        } else {
            world_matrix.columns.1 = SIMD4<Float>(bone_len * normalize(boneTangent), 0.0)
        }
        
        boneTangent = cross(bone_dir, world_matrix[1].xyz)
        if length_squared(boneTangent) < Float.leastNonzeroMagnitude {
            world_matrix.columns.2 = SIMD4<Float>(0, 0, 0, 0)
        } else {
            world_matrix.columns.2 = SIMD4<Float>(bone_len * normalize(boneTangent), 0.0)
        }
        
        world_matrix.columns.3 = SIMD4<Float>(joint3.xyz, 1.0)

        let cross_matrix = simd_float3x3(
        cross(world_matrix[1].xyz, world_matrix[2].xyz),
        cross(world_matrix[2].xyz, world_matrix[0].xyz),
        cross(world_matrix[0].xyz, world_matrix[1].xyz));
        let invdet = 1.0 / dot(cross_matrix[2], world_matrix[2].xyz);
        let normal_matrix = cross_matrix * invdet;
        return (Matrix(world_matrix), Matrix3x3(normal_matrix))
    }

    private func _createJointMesh() {
        let kNumSlices = 20
        let kNumPointsPerCircle = kNumSlices + 1
        let kNumPointsYZ = kNumPointsPerCircle
        let kNumPointsXY = kNumPointsPerCircle + 6
        let kNumPointsXZ = kNumPointsPerCircle
        let kNumPoints = kNumPointsXY + kNumPointsXZ + kNumPointsYZ
        let kRadius = kInter  // Radius multiplier.
        let red = Color32(r: 255, g: 0, b: 0)
        let green = Color32(r: 0, g: 255, b: 0)
        let blue = Color32(r: 0, g: 0, b: 255)

        // Fills vertices.
        joints.reserveCapacity(kNumPoints)
        var vertex = Gizmos.VertexPNC()
        for j in 0..<kNumPointsYZ {  // YZ plan.
            let angle = Float(j) * 2 * Float.pi / Float(kNumSlices)
            let s = sinf(angle), c = cosf(angle)
            vertex.pos = Vector3(0.0, c * kRadius, s * kRadius)
            vertex.normal = Vector3(0.0, c, s)
            vertex.color = red
            joints.append(vertex)
        }
        for j in 0..<kNumPointsXY {  // XY plan.
            let angle = Float(j) * 2 * Float.pi / Float(kNumSlices)
            let s = sinf(angle), c = cosf(angle)
            vertex.pos = Vector3(s * kRadius, c * kRadius, 0.0)
            vertex.normal = Vector3(s, c, 0.0)
            vertex.color = blue
            joints.append(vertex)
        }
        for j in 0..<kNumPointsXZ {  // XZ plan.
            let angle = Float(j) * 2 * Float.pi / Float(kNumSlices)
            let s = sinf(angle), c = cosf(angle)
            vertex.pos = Vector3(c * kRadius, 0.0, -s * kRadius)
            vertex.normal = Vector3(c, 0.0, -s)
            vertex.color = green
            joints.append(vertex)
        }
    }

    func _getJointWorldMatrix(_ joint0: SIMD4<Float>, _ joint1: SIMD4<Float>,
                              _ joint2: SIMD4<Float>, _ joint3: SIMD4<Float>) -> (modelMat: Matrix, normalMat: Matrix3x3) {
        // Rebuilds joint matrix.
        var joint_matrix = [SIMD4<Float>](repeating: SIMD4<Float>(), count: 4)
        joint_matrix[0] = SIMD4<Float>(normalize(joint0.xyz), 0.0)
        joint_matrix[1] = SIMD4<Float>(normalize(joint1.xyz), 0.0)
        joint_matrix[2] = SIMD4<Float>(normalize(joint2.xyz), 0.0)
        joint_matrix[3] = SIMD4<Float>(joint3.xyz, 1.0)

        // Rebuilds bone properties.
        let bone_dir = SIMD3<Float>(joint0.w, joint1.w, joint2.w)
        let bone_len = length(bone_dir)

        // Setup rendering world matrix.
        var world_matrix = simd_float4x4()
        world_matrix.columns.0 = joint_matrix[0] * bone_len
        world_matrix.columns.1 = joint_matrix[1] * bone_len
        world_matrix.columns.2 = joint_matrix[2] * bone_len
        world_matrix.columns.3 = joint_matrix[3]
        
        let cross_matrix = simd_float3x3(
        cross(world_matrix[1].xyz, world_matrix[2].xyz),
        cross(world_matrix[2].xyz, world_matrix[0].xyz),
        cross(world_matrix[0].xyz, world_matrix[1].xyz));
        let invdet = 1.0 / dot(cross_matrix[2], world_matrix[2].xyz);
        let normal_matrix = cross_matrix * invdet;
        return (Matrix(world_matrix), Matrix3x3(normal_matrix))
    }
}
