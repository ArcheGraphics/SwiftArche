//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// This script smoothes the position of a gameobject
public class SmoothPosition: Script {
    /// The target transform, whose position values will be copied and smoothed
    public var targetPosition: Vector3!
    var tr: Transform!

    var currentPosition = Vector3()

    /// Speed that controls how fast the current position will be smoothed toward the target position when 'Lerp' is selected as smoothType
    public var lerpSpeed: Float = 20

    /// Time that controls how fast the current position will be smoothed toward the target position when 'SmoothDamp' is selected as smoothType
    public var smoothDampTime: Float = 0.02

    /// Whether position values will be extrapolated to compensate for delay caused by smoothing
    public var extrapolatePosition = false

    /// 'UpdateType' controls whether the smoothing function is called in 'Update' or 'LateUpdate'
    public enum UpdateType {
        case Update
        case LateUpdate
    }

    public var updateType: UpdateType = .Update

    /// Different smoothtypes use different algorithms to smooth out the target's position
    public enum SmoothType {
        case Lerp
        case SmoothDamp
    }

    public var smoothType: SmoothType = .Lerp

    /// Local position offset at the start of the game
    var localPositionOffset = Vector3()

    var refVelocity = Vector3()

    public override func onAwake() {
        //If no target has been selected, choose this transform's parent as the target
        if (targetPosition == nil) {
            targetPosition = entity.parent?.transform.worldPosition ?? Vector3()
        }

        tr = entity.transform
        currentPosition = entity.transform.position
        localPositionOffset = tr.position
    }

    public override func onEnable() {
        //Reset current position when gameobject is re-enabled to prevent unwanted interpolation from last position
        ResetCurrentPosition()
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
        //Smooth current position
        currentPosition = Smooth(currentPosition, targetPosition, lerpSpeed)

        //Set position
        tr.position = currentPosition
    }

    func Smooth(_ start: Vector3, _ target: Vector3, _ smoothTime: Float) -> Vector3 {
        var target = target
        //Convert local position offset to world coordinates
        let _offset = Vector3.transformToVec3(v: localPositionOffset, m: tr.worldMatrix)

        //If 'extrapolateRotation' is set to 'true', calculate a new target position
        if (extrapolatePosition) {
            let difference = target - (start - _offset)
            target += difference
        }

        //Add local position offset to target
        target += _offset

        //Smooth (based on chosen smoothType) and return position
        switch (smoothType) {
        case SmoothType.Lerp:
            return Vector3.lerp(left: start, right: target, t: engine.time.deltaTime * smoothTime)
        case SmoothType.SmoothDamp:
            return Vector3.SmoothDamp(current: start, target: target, currentVelocity: &refVelocity,
                    smoothTime: smoothDampTime, deltaTime: engine.time.deltaTime)
        }
    }

    /// Reset stored position and move this gameobject directly to the target's position
    /// Call this function if the target has just been moved a larger distance and no interpolation should take place (teleporting)
    public func ResetCurrentPosition() {
        //Convert local position offset to world coordinates
        let _offset = Vector3.transformToVec3(v: localPositionOffset, m: tr.worldMatrix)
        //Add position offset and set current position
        currentPosition = targetPosition + _offset
    }
}
