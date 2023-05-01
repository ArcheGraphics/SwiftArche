//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiResourceHandle<T: AnyObject> {
    /// reference to the owner instance
    public var owner: T?
    /// index of this resource in the collision world.
    public var index: Int = -1
    /// amount of references to this handle. Can be used to clean up any associated resources after it reaches zero.
    private var referenceCount: Int = 0

    public var isValid: Bool { return index >= 0 }

    public func Invalidate() {
        index = -1
        referenceCount = 0
    }

    public func Reference() {
        referenceCount += 1
    }

    public func Dereference() -> Bool {
        referenceCount -= 1
        return referenceCount == 0
    }

    public init(index: Int = -1) {
        self.index = index
        owner = nil
    }
}

public class ObiColliderHandle: ObiResourceHandle<ObiColliderBase> {
    override public init(index: Int = -1) {
        super.init(index: index)
    }
}

public class ObiCollisionMaterialHandle: ObiResourceHandle<ObiCollisionMaterial> {
    override public init(index: Int = -1) {
        super.init(index: index)
    }
}

public class ObiRigidbodyHandle: ObiResourceHandle<ObiRigidbodyBase> {
    override public init(index: Int = -1) {
        super.init(index: index)
    }
}

public class ObiColliderWorld {
    public var implementations: [IColliderWorldImpl] = []
    /// list of collider handles, used by ObiCollider components to retrieve them./
    public var colliderHandles: [ObiColliderHandle] = []
    /// list of collider shapes.
    public var colliderShapes: [ColliderShape] = []
    /// list of collider bounds./
    public var colliderAabbs: [Aabb] = []
    /// list of collider transforms./
    public var colliderTransforms: [AffineTransform] = []

    public var materialHandles: [ObiCollisionMaterialHandle] = []
    /// list of collision materials./
    public var collisionMaterials: [ObiRigidbodyHandle] = []
    /// list of rigidbody handles, used by ObiRigidbody components to retrieve them./
    public var rigidbodyHandles: [ObiRigidbody] = []
    /// list of rigidbodies./
    public var rigidbodies: [ObiRigidbodyBase] = []

    public var triangleMeshContainer = ObiTriangleMeshContainer()
    public var distanceFieldContainer = ObiDistanceFieldContainer()
//    public var heightFieldContainer: ObiHeightFieldContainer
}
