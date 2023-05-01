//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render

/// Implements common functionality for ObiCollider and ObiCollider2D.
public class ObiColliderBase: Script {
    private var thickness: Float = 0

    private var material: ObiCollisionMaterial?

    private var filter: Int = 0

    var obiRigidbody: ObiRigidbodyBase?
    var wasUnityColliderEnabled = true
    var dirty = false

    /// tracker object used to determine when to update the collider's shape
    var tracker: ObiShapeTracker?

    /// Creates an OniColliderTracker of the appropiate type.
    func CreateTracker() {}

    func GetUnityCollider(enabled _: Bool) -> Component? {
        nil
    }

    func FindSourceCollider() {}

    func CreateRigidbody() {}

    func AddCollider() {}

    func RemoveCollider() {}

    /// Check if the collider transform or its shape have changed any relevant property, and update their Oni counterparts.
    public func UpdateIfNeeded() {}

    override public func onEnable() {}

    override public func onDisable() {}
}
