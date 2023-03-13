//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

public class KinematicPlatform: Script {
    // PT: Captures the state of the platform. We decouple this data from the platform itself so that the
    // same platform path (const data) can be used by several platform instances.
    struct PlatformState {
        var prevPosition = Vector3()
        var prevRotation = Quaternion()
        var currentTime: Float = 0
        var currentRotationTime: Float = 0
        var flip = false
    }

    public enum LoopMode {
        case LOOP_FLIP
        case LOOP_WRAP
    }
    
    var state = PlatformState()
    var platform: DynamicCollider?

    /// points
    public var points: [Vector3] = []
    /// loop mode
    public var mode = LoopMode.LOOP_FLIP
    /// travel time
    public var travelTime: Float = 0
    /// rotation speed
    public var rotationSpeed: Float = 0
    
    /// previous position
    public var prePosition: Vector3 {
        state.prevPosition
    }
    /// previous rotation
    public var preRotation: Quaternion {
        state.prevRotation
    }
    /// points segment count
    public var segmentsCount: Int {
        points.count - 1
    }
    
    public func setDefaultTravelTime(platformSpeed: Float) {
        let pathLength = computeLength()
        travelTime = pathLength / platformSpeed
    }
    
    public func reset() {
        state = PlatformState()
    }

    public func computeLength() -> Float {
        var totalLength: Float = 0.0
        for i in 0..<segmentsCount {
            let a = i % points.count
            let b = (i + 1) % points.count
            totalLength += (points[b] - points[a]).length()
        }
        return totalLength
    }

    public func getPoint(_ p: inout Vector3, seg: Int, t: Float) -> Bool {
        let a = seg % points.count
        let b = (seg + 1) % points.count
        let p0 = points[a]
        let p1 = points[b]
        p = (1.0 - t) * p0 + t * p1
        return true
    }

    public func getPoint(_ p: inout Vector3, t: Float) -> Bool {
        let totalLength = computeLength()
        let coeff = 1.0 / totalLength

        var currentLength: Float = 0.0
        for i in 0..<segmentsCount {
            let a = i % points.count
            let b = (i + 1) % points.count
            let length = coeff * (points[b] - points[a]).length()

            if (t >= currentLength && t <= currentLength + length) {
                // Desired point is on current segment
                // currentLength maps to 0.0
                // currentLength+length maps to 1.0
                let nt = (t - currentLength) / (length)
                return getPoint(&p, seg: i, t: nt)
            }
            currentLength += length
        }
        return false
    }

    required init(_ entity: Entity) {
        platform = entity.getComponent(DynamicCollider.self)
        if let platform {
            platform.isKinematic = true
        }
        super.init(entity)
    }

    public override func onUpdate(_ deltaTime: Float) {
        state.currentTime += deltaTime
        state.currentRotationTime += deltaTime

        // Compute current position on the path
        var t = state.currentTime / travelTime
        if (t > 1.0) {
            if (mode == .LOOP_FLIP) {
                state.flip = !state.flip
                // Make it loop
                state.currentTime = fmodf(state.currentTime, travelTime)
                t = state.currentTime / travelTime
            } else {
                t = 1.0 - t
                state.currentTime = t * travelTime
            }
        }

        var currentPos = Vector3()
        if (getPoint(&currentPos, t: state.flip ? 1.0 - t : t)) {
            state.prevPosition = currentPos
            state.prevRotation = entity.transform.worldRotationQuaternion * Quaternion.rotationX(rad: state.currentRotationTime * rotationSpeed)
            if let platform {
                platform.movePosition(state.prevPosition)
                platform.moveRotation(state.prevRotation)
            }
        }
    }
}
