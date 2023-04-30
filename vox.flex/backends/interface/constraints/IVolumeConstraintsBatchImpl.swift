//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IVolumeConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetVolumeConstraints(triangles: [Int],
                              firstTriangle: [Int],
                              numTriangles: [Int],
                              restVolumes: [Float],
                              pressureStiffness: [Vector2],
                              lambdas: [Float],
                              count: Int)
}
