//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public class Teleporter: Script {
    public var TeleportTo: Teleporter?

    public var OnCharacterTeleport: ((ExampleCharacterController) -> Void)?

    public var isBeingTeleportedTo: Bool = false

    public override func onTriggerEnter(_ other: ColliderShape) {
        if (!isBeingTeleportedTo) {

            if let TeleportTo = TeleportTo,
               let cc: ExampleCharacterController = other.collider!.entity.getComponent() {
                cc.Motor!.SetPositionAndRotation(TeleportTo.entity.transform.position, TeleportTo.entity.transform.rotationQuaternion)

                if let OnCharacterTeleport = OnCharacterTeleport {
                    OnCharacterTeleport(cc)
                }
                TeleportTo.isBeingTeleportedTo = true
            }
        }

        isBeingTeleportedTo = false
    }
}
