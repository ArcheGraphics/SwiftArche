//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IShapeMatchingConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetShapeMatchingConstraints(particleIndices: [Int],
                                     firstIndex: [Int],
                                     numIndices: [Int],
                                     explicitGroup: [Int],
                                     shapeMaterialParameters: [Float],
                                     restComs: [Vector4],
                                     coms: [Vector4],
                                     orientations: [Quaternion],
                                     linearTransforms: [Matrix],
                                     plasticDeformations: [Matrix],
                                     lambdas: [Float],
                                     count: Int)

    func CalculateRestShapeMatching()
}
