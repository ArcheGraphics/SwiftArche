//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct XCameraKeypoint {
    /// Position of the keypoint.
    var position = Vector3()
    /// Forward direction at the keypoint.
    var forward = Vector3()
    /// Up direction at the keypoint.
    var up = Vector3()
    /// Selected light environment at the keypoint.
    var lightEnv: Int = 0

    // Constructors.
    init() {
    }

    init(_ pos: Vector3, _ forward: Vector3, _ up: Vector3, _ lightEnv: Int) {
        position = pos
        self.forward = forward
        self.up = up
        self.lightEnv = lightEnv
    }
}

/// Stores a list of keypoints.
///  Supports attaching to a camera, then updates to the controller time with
///  `updateTimeInSeconds` updates the camera transform.
///  Keypoints can be added and removed and serialized to/from file.
class XCameraController {
    /// The camera attached to this controller.
    var _attachedCamera: XCamera!
    /// Current progress throught the keypoints.
    var _progress: Float = 0
    /// Storage for the keypoints.
    var _keypoints: [XCameraKeypoint] = []
    /// Internal array of distances to keypoints from first keypoint.
    var _distances: [Float] = []
    /// Total of all the keypoint distances.
    var _totalDistance: Float = 0.0

    /// Flag to indicate looping mode:
    ///  Looping mode interpolates from end to start
    ///  Otherwise it resets to the start after the end with no interpolation.
    var _loop: Bool = false
    /// Flag to indicate that custom distances were loaded from file and should  not be overwritten.
    var _loadedDistances: Bool = false

    /// Current light environment interpolation.
    var _lightEnvA: Int = 0
    var _lightEnvB: Int = 0
    var _lightEnvInterp: Float = 0.0

    var _keypointCount: Int = 0

    init() {
    }

    /// Multiplier for update time to control movement speed.
    var movementSpeed: Float = 1.0

    /// Flag to indicate that this controller is enabled.
    var enabled: Bool = false

    /// Total length of path in seconds.
    var totalDistance: Float {
        _totalDistance
    }

    var keypointCount: Int {
        _keypoints.count
    }

    // Runtime usage - attach, update or move to a new keypoint.
    func attach(to camera: XCamera) {
        _attachedCamera = camera
        _progress = 0
    }

    func updateTime(in seconds: CFAbsoluteTime) {
        if (_keypoints.count < 2) {
            return
        }

        _progress += Float(seconds) * movementSpeed
        _progress = fmod(_progress, length)

        let pos = getPosition(at: _progress)
        _attachedCamera.position = pos
        _attachedCamera.face(direction: getForward(at: _progress), withUp: Vector3(0, 1, 0))

        getLightEnv(at: _progress, outA: &_lightEnvA, outB: &_lightEnvB, outInterp: &_lightEnvInterp)
    }

    func moveTo(index: Int) {
        if (index < _keypoints.count) {
            _progress = index > 0 ? _distances[index - 1] : 0.0
        }
    }

    // MARK: - keypoint
    /// Keypoint access and modification.
    func addKeypoint(at position: Vector3,
                     forward: Vector3,
                     up: Vector3,
                     lightEnv: Int) {
        _keypoints.append(XCameraKeypoint(position, forward, up, lightEnv))
    }

    func updateKeypoint(_ index: Int,
                        position: Vector3,
                        forward: Vector3,
                        up: Vector3) {
        if index < _keypoints.count {
            _keypoints[index].position = position
            _keypoints[index].forward = forward
            _keypoints[index].up = up
            if (!_loadedDistances) {
                updateDistances()
            }
        }
    }

    func clearKeypoints() {
        _keypoints = []
    }

    func popKeypoint() {
        _ = _keypoints.popLast()
        if (!_loadedDistances) {
            updateDistances()
        }
    }

    func getKeypoints(_ outKeypoints: inout [Vector3], outForwards: inout [Vector3]) {
        let length = _keypoints.count
        for i in 0..<length {
            outKeypoints.append(_keypoints[i].position)
            outForwards.append(_keypoints[i].forward)
        }
    }

    func getLightEnv(outInterp: inout Float, outA: inout Int, outB: inout Int) {
        outInterp = _lightEnvInterp
        outA = _lightEnvA
        outB = _lightEnvB
    }

    // MARK: - Private
    /// Internal method to calculate length limit for keypoint path.
    private var length: Float {
        _totalDistance > 0.0 ? _totalDistance : Float(_keypoints.count)
    }

    /// Internal method to calculate the index of the element at time t.
    private func index(for time: Float, t: inout Float) -> Int {
        if _totalDistance == 0.0 {
            t = fmod(time, 1.0)
            return Int(time)
        }

        var lastDistance: Float = 0.0
        for i in 0..<_distances.count {
            let distance = _distances[i]
            if time < distance {
                t = (time - lastDistance) / (distance - lastDistance)
                return i
            }
            lastDistance = distance
        }
        t = 0.0
        return 0
    }

    /// Internal method to populate the _distances array.
    private func updateDistances() {
        // Use linear mode for getPositionAt
        _totalDistance = 0.0
        // Accumulate locally
        var totalDistance: Float = 0.0

        var p = getPosition(at: 0)

        let length = _keypoints.count
        _distances = .init(repeating: 0, count: length)
        for i in 0..<length {
            let steps = 32
            var distance: Float = 0.0
            for j in 0..<steps {
                let q = getPosition(at: Float(i) + Float(j) / Float(steps))
                distance += (p - q).length()
                p = q
            }
            totalDistance += distance
            _distances[i] = totalDistance
        }
        _totalDistance = totalDistance
    }

    /// Internal method to calculate the indices for interpolation at time t.
    private func getIndices(at time: Float,
                            t: inout Float,
                            kp0: inout Int,
                            kp1: inout Int,
                            kp2: inout Int,
                            kpprev: inout Int) {
        let loopedTime = fmod(time, length)
        kp0 = index(for: loopedTime, t: &t)
        if (_loop) {
            kp1 = (kp0 + 1) % _keypoints.count
            kp2 = (kp0 + 2) % _keypoints.count
            kpprev = (kp0 + _keypoints.count - 1) % _keypoints.count
        } else {
            kp1 = min(kp0 + 1, _keypoints.count - 1)
            kp2 = min(kp0 + 2, _keypoints.count - 1)
            kpprev = max(kp0 - 1, 0)
        }
    }

    /// Internal function to perform the interpolation for interpolant t.
    private static func interpolate(for t: Float, p0: Vector3, p1: Vector3, p2: Vector3,
                                    pprev: Vector3) -> Vector3 {
        let i: Float = t
        let i2: Float = i * i
        let i3: Float = i * i * i

        let m0: Vector3 = ((p1 - p0) + (p0 - pprev)) * 0.5
        let m1: Vector3 = ((p2 - p1) + (p1 - p0)) * 0.5

        var pos: Vector3 = p0 * (2.0 * i3 - 3 * i2 + 1.0)
        pos += p1 * (-2.0 * i3 + 3 * i2)
        pos += m0 * (i3 - 2 * i2 + i)
        pos += m1 * (i3 - i2)

        return pos
    }

    private func getPosition(at time: Float) -> Vector3 {
        if (_keypoints.count == 1) {
            return _keypoints[0].position
        }

        var t: Float = 0
        var kp0: Int = 0, kp1: Int = 0, kp2: Int = 0, kpprev: Int = 0
        getIndices(at: time, t: &t, kp0: &kp0, kp1: &kp1, kp2: &kp2, kpprev: &kpprev)

        let p0 = _keypoints[kp0].position
        let p1 = _keypoints[kp1].position
        let p2 = _keypoints[kp2].position
        let pprev = _keypoints[kpprev].position

        return XCameraController.interpolate(for: t, p0: p0, p1: p1, p2: p2, pprev: pprev)
    }

    private func getForward(at time: Float) -> Vector3 {
        if (_keypoints.count == 1) {
            return _keypoints[0].forward
        }

        var t: Float = 0
        var kp0: Int = 0, kp1: Int = 0, kp2: Int = 0, kpprev: Int = 0
        getIndices(at: time, t: &t, kp0: &kp0, kp1: &kp1, kp2: &kp2, kpprev: &kpprev)

        let p0 = _keypoints[kp0].forward
        let p1 = _keypoints[kp1].forward
        let p2 = _keypoints[kp2].forward
        let pprev = _keypoints[kpprev].forward

        return XCameraController.interpolate(for: t, p0: p0, p1: p1, p2: p2, pprev: pprev)
    }

    private func getLightEnv(at time: Float, outA: inout Int, outB: inout Int, outInterp: inout Float) {
        if (_keypoints.count == 1) {
            outA = _keypoints[0].lightEnv
            outB = _keypoints[0].lightEnv
            outInterp = 0.0
        }

        let loopedTime = fmod(time, length)

        var t: Float = 0
        let kp0 = index(for: loopedTime, t: &t)
        var kpprev = (kp0 + _keypoints.count - 1) % _keypoints.count

        if (!_loop) {
            kpprev = max(kp0 - 1, 0)
        }

        let p0 = _keypoints[kp0].lightEnv
        let pprev = _keypoints[kpprev].lightEnv

        outA = pprev
        outB = p0
        outInterp = t
    }
}
