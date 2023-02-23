//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public struct ConvexHull {
    public var points: [SIMD3<Float>]
    public var triangles: [SIMD3<UInt32>]
}

public class ConvexCompose {
    private let vhacd = VHACD_ConvexCompose()
    private var _convexHulls: [ConvexHull] = []
    
    /// The maximum number of convex hulls to produce
    public var maxConvexHulls: UInt32 {
        get {
            vhacd.maxConvexHulls
        }
        set {
            vhacd.maxConvexHulls = newValue
        }
    }
    
    /// The voxel resolution to use
    public var resolution: UInt32 {
        get {
            vhacd.resolution
        }
        set {
            vhacd.resolution = newValue
        }
    }
    
    /// if the voxels are within 1% of the volume of the hull, we consider this a close enough approximation
    public var minimumVolumePercentErrorAllowed: Double {
        get {
            vhacd.minimumVolumePercentErrorAllowed
        }
        set {
            vhacd.minimumVolumePercentErrorAllowed = newValue
        }
    }
    
    /// The maximum recursion depth
    public var maxRecursionDepth: UInt32 {
        get {
            vhacd.maxRecursionDepth
        }
        set {
            vhacd.maxRecursionDepth = newValue
        }
    }
    
    /// Whether or not to shrinkwrap the voxel positions to the source mesh on output
    public var shrinkWrap: Bool {
        get {
            vhacd.shrinkWrap
        }
        set {
            vhacd.shrinkWrap = newValue
        }
    }
    /// How to fill the interior of the voxelized mesh
    public var fillMode: VHACD_FillMode {
        get {
            vhacd.fillMode
        }
        set {
            vhacd.fillMode = newValue
        }
    }
    
    /// The maximum number of vertices allowed in any output convex hull
    public var maxNumVerticesPerCH: UInt32 {
        get {
            vhacd.maxNumVerticesPerCH
        }
        set {
            vhacd.maxNumVerticesPerCH = newValue
        }
    }
    
    /// Whether or not to run asynchronously, taking advantage of additional cores
    public var asyncACD: Bool {
        get {
            vhacd.asyncACD
        }
        set {
            vhacd.asyncACD = newValue
        }
    }
    
    /// Once a voxel patch has an edge length of less than 4 on all 3 sides, we don't keep recursing
    public var minEdgeLength: UInt32 {
        get {
            vhacd.minEdgeLength
        }
        set {
            vhacd.minEdgeLength = newValue
        }
    }
    
    /// Whether or not to attempt to split planes along the best location. Experimental feature. False by default.
    public var findBestPlane: Bool {
        get {
            vhacd.findBestPlane
        }
        set {
            vhacd.findBestPlane = newValue
        }
    }
    
    public var convexHulls: [ConvexHull] {
        get {
            _convexHulls
        }
    }
    
    public func compute(for mesh: ModelMesh) {
        _convexHulls = []
        
        let points = mesh.getPositions()!
        var floatArray: [Float] = []
        floatArray.reserveCapacity(points.count * 3)
        points.forEach { v in
            floatArray.append(v.x)
            floatArray.append(v.y)
            floatArray.append(v.z)
        }
        
        var indices: [UInt32]? = mesh.getIndices()
        if indices == nil {
            let indices16: [UInt16]? = mesh.getIndices()
            if let indices16 = indices16 {
                indices = indices16.map({ v in
                    UInt32(v)
                })
            }
        }
        
        if var indices = indices {
            vhacd.compute(withPoints: &floatArray, pointsCount: UInt32(points.count),
                          indices: &indices, indicesCount: UInt32(indices.count))
            
            let hullCount = vhacd.hullCount()
            _convexHulls.reserveCapacity(Int(hullCount))
            for i in 0..<hullCount {
                var points = [SIMD3<Float>](repeating: SIMD3<Float>(), count: Int(vhacd.pointCount(at: i)))
                var triangles = [SIMD3<UInt32>](repeating: SIMD3<UInt32>(), count: Int(vhacd.triangleCount(at: i)))
                vhacd.getPointAndTriangle(at: i, points: &points, indices: &triangles)
                _convexHulls.append(ConvexHull(points: points, triangles: triangles))
            }
        }
    }
}
