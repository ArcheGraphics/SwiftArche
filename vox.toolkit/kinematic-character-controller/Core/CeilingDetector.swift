//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// This (optional) component can be added to a gameobject that also has a 'AdvancedWalkerController' attached
/// It will continuously check all collision detected by the internal physics calculation
/// If a collision qualifies as the character "hitting a ceiling" (based on surface normal), the result will be stored
/// The 'AdvancedWalkerController' then can use that information to react to ceiling hits
public class CeilingDetector: Script {
    var ceilingWasHit = false

    /// Angle limit for ceiling hits
    public var ceilingAngleLimit: Float = 10

    /// Ceiling detection methods
    public enum CeilingDetectionMethod {
        /// 'OnlyCheckFirstContact' - Only check the very first collision contact. This option is slightly faster but less accurate than the other two options.
        case OnlyCheckFirstContact
        /// 'CheckAllContacts' - Check all contact points and register a ceiling hit as long as just one contact qualifies.
        case CheckAllContacts
        /// 'CheckAverageOfAllContacts' - Calculate an average surface normal to check against.
        case CheckAverageOfAllContacts
    }

    public var ceilingDetectionMethod = CeilingDetectionMethod.CheckAllContacts

    /// If enabled, draw debug information to show hit positions and hit normals
    public var isInDebugMode: Bool = false
    /// How long debug information is drawn on the screen
    var debugDrawDuration: Float = 2.0

    var tr: Transform!

    public override func onAwake() {
        tr = entity.transform
    }

    public override func onCollisionEnter(_ other: Collision) {
        CheckCollisionAngles(other)
    }

    public override func onCollisionStay(_ other: Collision) {
        CheckCollisionAngles(other)
    }

    //Check if a given collision qualifies as a ceiling hit
    private func CheckCollisionAngles(_ _collision: Collision) {
        var _angle: Float = 0

        if (ceilingDetectionMethod == CeilingDetectionMethod.OnlyCheckFirstContact) {
            //Calculate angle between hit normal and character
            _angle = Vector3.angle(from: -tr.worldUp, to: Vector3(_collision.contacts[0].normal))

            //If angle is smaller than ceiling angle limit, register ceiling hit
            if (_angle < ceilingAngleLimit) {
                ceilingWasHit = true
            }
        }
        if (ceilingDetectionMethod == CeilingDetectionMethod.CheckAllContacts) {
            for i in 0..<_collision.contacts.count {
                //Calculate angle between hit normal and character
                _angle = Vector3.angle(from: -tr.worldUp, to: Vector3(_collision.contacts[i].normal))

                //If angle is smaller than ceiling angle limit, register ceiling hit
                if (_angle < ceilingAngleLimit) {
                    ceilingWasHit = true
                }
            }
        }
        if (ceilingDetectionMethod == CeilingDetectionMethod.CheckAverageOfAllContacts) {
            for i in 0..<_collision.contacts.count {
                //Calculate angle between hit normal and character and add it to total angle count
                _angle += Vector3.angle(from: -tr.worldUp, to: Vector3(_collision.contacts[i].normal))
            }

            //If average angle is smaller than the ceiling angle limit, register ceiling hit
            if (_angle / Float(_collision.contacts.count) < ceilingAngleLimit) {
                ceilingWasHit = true
            }
        }
    }

    //Return whether ceiling was hit during the last frame
    public var HitCeiling: Bool {
        return ceilingWasHit
    }

    //Reset ceiling hit flags
    public func ResetFlags() {
        ceilingWasHit = false
    }
}
