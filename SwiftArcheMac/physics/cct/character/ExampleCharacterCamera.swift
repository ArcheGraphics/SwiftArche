//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public class ExampleCharacterCamera: Script {
    // MARK: - "Framing"
    public var Camera: Camera?
    public var FollowPointFraming = Vector2(0, 0)
    public var FollowingSharpness: Float = 10000

    // MARK: - "Distance"
    public var DefaultDistance: Float = 6
    public var MinDistance: Float = 0
    public var MaxDistance: Float = 10
    public var DistanceMovementSpeed: Float = 5
    public var DistanceMovementSharpness: Float = 10

    // MARK: - "Rotation"
    public var InvertX = false
    public var InvertY = false
    public var DefaultVerticalAngle: Float = 20
    public var MinVerticalAngle: Float = -90
    public var MaxVerticalAngle: Float = 90
    public var RotationSpeed: Float = 1
    public var RotationSharpness: Float = 10000
    public var RotateWithPhysicsMover = false

    // MARK: - "Obstruction"
    public var ObstructionCheckRadius: Float = 0.2
    public var ObstructionLayers: Layer = []
    public var ObstructionSharpness: Float = 10000
    public var IgnoredColliders: [Collider] = []

    public var Transform: Transform!
    public var FollowTransform: Transform?

    public var PlanarDirection: Vector3!
    public var TargetDistance: Float!

    private var _distanceIsObstructed: Bool = false
    private var _currentDistance: Float!
    private var _targetVerticalAngle: Float = 0
    private var _obstructionHit = HitResult()
    private var _obstructionCount: Int = 0
    private var _obstructions = [HitResult](repeating: HitResult(), count: MaxObstructions)
    private var _obstructionTime: Float = 0
    private var _currentFollowPosition = Vector3()

    private static let MaxObstructions = 32

    public required init(_ entity: Entity) {
        super.init(entity)
    }

    public override func onAwake() {
        Transform = entity.transform

        _currentDistance = DefaultDistance
        TargetDistance = _currentDistance

        _targetVerticalAngle = 0

        PlanarDirection = Vector3.forward
    }

    /// Set the transform that the camera will orbit around
    public func SetFollowTransform(_ t: Transform) {
        FollowTransform = t
        PlanarDirection = t.worldForward
        _currentFollowPosition = t.position
    }

    public func UpdateWithInput(deltaTime: Float, zoomInput: Float, rotationInput: Vector3) {
        var rotationInput = rotationInput
        if let FollowTransform = FollowTransform {
            if (InvertX) {
                rotationInput.x *= -1
            }
            if (InvertY) {
                rotationInput.y *= -1
            }

            // Process rotation input
            let up = FollowTransform.worldUp * (rotationInput.x * RotationSpeed)
            let rotationFromInput = Quaternion.rotationEuler(x: up.x, y: up.y, z: up.z)
            PlanarDirection = Vector3.transformByQuat(v: PlanarDirection, quaternion: rotationFromInput)
            PlanarDirection = Vector3.cross(left: FollowTransform.worldUp, right: Vector3.cross(left: PlanarDirection, right: FollowTransform.worldUp))
            let planarRot = Matrix.lookAt(eye: Vector3(), target: PlanarDirection, up: FollowTransform.worldUp).getRotation()

            _targetVerticalAngle -= (rotationInput.y * RotationSpeed)
            _targetVerticalAngle = simd_clamp(_targetVerticalAngle, MinVerticalAngle, MaxVerticalAngle)
            let verticalRot = Quaternion.rotationEuler(x: _targetVerticalAngle, y: 0, z: 0)
            let targetRotation = Quaternion.slerp(start: Transform.rotationQuaternion, end: planarRot * verticalRot, t: 1 - exp(-RotationSharpness * deltaTime))

            // Apply rotation
            Transform.rotationQuaternion = targetRotation

            // Process distance input
            if (_distanceIsObstructed && abs(zoomInput) > 0) {
                TargetDistance = _currentDistance
            }
            TargetDistance += zoomInput * DistanceMovementSpeed
            TargetDistance = simd_clamp(TargetDistance, MinDistance, MaxDistance)

            // Find the smoothed follow position
            _currentFollowPosition = Vector3.lerp(left: _currentFollowPosition, right: FollowTransform.position, t: 1 - exp(-FollowingSharpness * deltaTime))

            // Handle obstructions
            var closestHit = HitResult()
            closestHit.distance = Float.infinity
            let shape = SphereColliderShape()
            shape.radius = ObstructionCheckRadius
            _obstructions = engine.physicsManager.sweepAll(shape: shape, position: _currentFollowPosition, rotation: Quaternion(),
                    dir: -Transform.worldForward, distance: TargetDistance, layerMask: ObstructionLayers)
            _obstructionCount = _obstructions.count
            for i in 0..<_obstructionCount {
                var isIgnored = false
                for j in 0..<IgnoredColliders.count {
                    if (IgnoredColliders[j] == _obstructions[i].collider) {
                        isIgnored = true
                        break
                    }
                }
                for j in 0..<IgnoredColliders.count {
                    if (IgnoredColliders[j] == _obstructions[i].collider) {
                        isIgnored = true
                        break
                    }
                }

                if (!isIgnored && _obstructions[i].distance < closestHit.distance && _obstructions[i].distance > 0) {
                    closestHit = _obstructions[i]
                }
            }

            // If obstructions detecter
            if (closestHit.distance < Float.infinity) {
                _distanceIsObstructed = true
                _currentDistance = simd_mix(_currentDistance, closestHit.distance, 1 - exp(-ObstructionSharpness * deltaTime))
            }
            // If no obstruction
            else {
                _distanceIsObstructed = false
                _currentDistance = simd_mix(_currentDistance, TargetDistance, 1 - exp(-DistanceMovementSharpness * deltaTime))
            }


            // Find the smoothed camera orbit position
            var targetPosition = _currentFollowPosition - (Vector3.transformByQuat(v: Vector3.forward, quaternion: targetRotation) * _currentDistance)

            // Handle framing
            targetPosition += Transform.worldRight * FollowPointFraming.x
            targetPosition += Transform.worldUp * FollowPointFraming.y

            // Apply position
            Transform.position = targetPosition
        }
    }
}
