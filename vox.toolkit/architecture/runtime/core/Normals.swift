//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public enum Normals {
    static var s_SmoothAvg = [Vector3](repeating: Vector3(), count: Smoothing.smoothRangeMax)
    static var s_SmoothAvgCount = [Float](repeating: 0, count: Smoothing.smoothRangeMax)
    static var s_CachedIntArray = [Int](repeating: 0, count: Int(UInt8.max))

    static func ClearIntArray(count _: Int) {}

    public static func CalculateTangents(mesh _: ProBuilderMesh) {}

    /// Calculate mesh normals without taking into account smoothing groups.
    /// - Parameter mesh: A new array of the vertex normals.
    static func CalculateHardNormals(mesh _: ProBuilderMesh) {}

    /// Calculates the normals for a mesh, taking into account smoothing groups.
    /// - Parameter mesh: A Vector3 array of the mesh normals
    public static func CalculateNormals(mesh _: ProBuilderMesh) {}
}
