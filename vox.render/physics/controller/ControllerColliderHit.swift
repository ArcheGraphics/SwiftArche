//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ControllerColliderHit {
    public var colliderShape: ColliderShape?
    public var collider: Collider?
    public var entity: Entity?
    public weak var controller: CharacterController?

    public var moveDirection = Vector3()
    public var moveLength: Float = 0
    public var normal = Vector3()
    public var point = Vector3()

    public init(_ controller: CharacterController) {
        self.controller = controller
    }
}
