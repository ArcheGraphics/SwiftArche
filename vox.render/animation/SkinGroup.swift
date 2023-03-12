//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class SkinGroup {
    private var _nativeGroup = CSkinGroup()
    
    public var skinCount: Int {
        Int(_nativeGroup.skinCount())
    }
    
    public init(_ url: URL) {
        loadSkin(url)
    }
    
    public func loadSkin(_ url: URL) {
        _nativeGroup.loadSkin(url.path(percentEncoded: false))
    }
    
    public func vertexCount(at index: Int) -> Int {
        Int(_nativeGroup.vertexCount(at: UInt32(index)))
    }
    
    public func skinningMatricesCount(at index: Int) -> Int {
        Int(_nativeGroup.skinningMatricesCount(at: UInt32(index)))
    }
    
    public func getMeshData(at index: Int, positions: inout [Float],
                            normals: inout [Float],
                            tangents: inout [Float],
                            uvs: inout [Float],
                            joint_indices: inout [Float],
                            joint_weights: inout [Float],
                            colors: inout [Float],
                            indices: inout [UInt16]) {
        _nativeGroup.getMeshData(at: UInt32(index), &positions, &normals, &tangents, &uvs,
                                 &joint_indices, &joint_weights, &colors, &indices)
    }
    
    public func getSkinningMatrices(at index: Int, animator: Animator, matrix: inout [simd_float4x4]) {
        _nativeGroup.getSkinningMatrices(at: UInt32(index), animator._nativeAnimator, &matrix)
    }
}
