//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public enum MeshColliderCookingOptions: UInt8 {
    // Toggle the removal of equal vertices.
    case WeldColocatedVertices = 1
    // Toggle cleaning of the mesh.
    case EnableMeshCleaning = 2
    // Toggle between cooking for faster simulation or faster cooking time.
    case CookForFasterSimulation = 4
}
