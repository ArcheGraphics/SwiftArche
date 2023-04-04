//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public protocol Shape {
    func UpdateBounds(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion, bounds: Bounds) -> Bounds

    func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds

    func CopyShape(_ shape: Shape)
}

public extension Shape {
    func UpdateBounds(mesh: ProBuilderMesh, size _: Vector3, rotation _: Quaternion, bounds _: Bounds) -> Bounds {
        mesh.mesh!.bounds
    }
}
