//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// This script smoothes the rotation of a gameobject
public class SmoothRotation: Script {

    /// The target transform, whose rotation values will be copied and smoothed
    public var targetRotation: Quaternion!
    var tr: Transform!

    var currentRotation = Quaternion()

    /// Speed that controls how fast the current rotation will be smoothed toward the target rotation
    public var smoothSpeed: Float = 20

    /// Whether rotation values will be extrapolated to compensate for delay caused by smoothing
    public var extrapolateRotation = false

    /// 'UpdateType' controls whether the smoothing function is called in 'Update' or 'LateUpdate'
    public enum UpdateType {
        case Update
        case LateUpdate
    }

    public var updateType: UpdateType = .Update

    public override func onAwake() {
        if targetRotation == nil {
            targetRotation = entity.parent?.transform.rotationQuaternion ?? Quaternion()
        }
        tr = entity.transform
        currentRotation = entity.transform.rotationQuaternion
    }

    public override func onEnable() {
        //Reset current rotation when gameobject is re-enabled to prevent unwanted interpolation from last rotation
        ResetCurrentRotation()
    }

    public override func onUpdate(_ deltaTime: Float) {
        if (updateType == UpdateType.LateUpdate) {
            return
        }
        SmoothUpdate()
    }

    public override func onLateUpdate(_ deltaTime: Float) {
        if (updateType == UpdateType.Update) {
            return
        }
        SmoothUpdate()
    }

    func SmoothUpdate() {
        //Smooth current rotation
        currentRotation = Smooth(currentRotation, targetRotation, smoothSpeed)

        //Set rotation
        tr.rotationQuaternion = currentRotation
    }

    //Smooth a rotation toward a target rotation based on 'smoothTime'
    func Smooth(_ currentRotation: Quaternion, _ targetRotation: Quaternion, _ smoothSpeed: Float) -> Quaternion {
        var targetRotation = targetRotation
        //If 'extrapolateRotation' is set to 'true', calculate a new target rotation
        if (extrapolateRotation && Quaternion.angle(currentRotation, targetRotation) < 90) {
            let difference = targetRotation * Quaternion.invert(a: currentRotation)
            targetRotation *= difference
        }

        //Slerp rotation and return
        return Quaternion.slerp(start: currentRotation, end: targetRotation, t: engine.time.deltaTime * smoothSpeed)
    }

    //Reset stored rotation and rotate this gameobject to macth the target's rotation
    //Call this function if the target has just been rotatedand no interpolation should take place (instant rotation)
    public func ResetCurrentRotation() {
        currentRotation = targetRotation
    }
}
