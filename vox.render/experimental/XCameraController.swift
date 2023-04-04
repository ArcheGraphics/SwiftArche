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
    init() {}

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
    /// Current progress through the keypoints.
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

    init() {}

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
        if _keypoints.count < 2 {
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
        if index < _keypoints.count {
            _progress = index > 0 ? _distances[index - 1] : 0.0
        }
    }

    // MARK: - keypoint

    /// Keypoint access and modification.
    func addKeypoint(at position: Vector3,
                     forward: Vector3,
                     up: Vector3,
                     lightEnv: Int)
    {
        _keypoints.append(XCameraKeypoint(position, forward, up, lightEnv))
    }

    func updateKeypoint(_ index: Int,
                        position: Vector3,
                        forward: Vector3,
                        up: Vector3)
    {
        if index < _keypoints.count {
            _keypoints[index].position = position
            _keypoints[index].forward = forward
            _keypoints[index].up = up
            if !_loadedDistances {
                updateDistances()
            }
        }
    }

    func clearKeypoints() {
        _keypoints = []
    }

    func popKeypoint() {
        _ = _keypoints.popLast()
        if !_loadedDistances {
            updateDistances()
        }
    }

    func getKeypoints(_ outKeypoints: inout [Vector3], outForwards: inout [Vector3]) {
        let length = _keypoints.count
        for i in 0 ..< length {
            outKeypoints.append(_keypoints[i].position)
            outForwards.append(_keypoints[i].forward)
        }
    }

    func getLightEnv(outInterp: inout Float, outA: inout Int, outB: inout Int) {
        outInterp = _lightEnvInterp
        outA = _lightEnvA
        outB = _lightEnvB
    }

    func saveKeypoint(to file: String) {
        if let path = getOrCreateApplicationSupportPath() {
            let filename = String(format: "%@/%@.waypoints", path, file)

            var data = ""

            let length = _keypoints.count
            assert(_distances.count == length)

            for i in 0 ..< length {
                data += String(format: "p %f %f %f\n", _keypoints[i].position.x, _keypoints[i].position.y, _keypoints[i].position.z)
                data += String(format: "f %f %f %f\n", _keypoints[i].forward.x, _keypoints[i].forward.y, _keypoints[i].forward.z)
                data += String(format: "u %f %f %f\n", _keypoints[i].up.x, _keypoints[i].up.y, _keypoints[i].up.z)
                data += String(format: "le %u\n", _keypoints[i].lightEnv)
                data += String(format: "t %f\n", _distances[i])
                data += String(format: "x\n")
            }
            try? data.write(toFile: filename, atomically: false, encoding: .utf8)
            logger.log(level: .info, "Written \(length) keypoints to \(filename)")
        }
    }

    func loadKeypoint(from file: String) -> Bool {
        // Start in app bundle, then look in app support path
        let url = Bundle.main.url(forResource: file, withExtension: "waypoints")
        if url == nil {
            logger.error("Could not find resource \(file)")
            return false
        }

        let filename = url?.path(percentEncoded: false)
        let fileContents = try? String(contentsOfFile: filename!, encoding: .utf8)
        let allLines = fileContents?.components(separatedBy: CharacterSet.newlines)

        var kp = XCameraKeypoint()
        _distances = []
        if let allLines {
            for line in allLines {
                if line == "x" {
                    _keypoints.append(kp)
                    kp = XCameraKeypoint()
                } else {
                    let ks = line.components(separatedBy: " ")

                    if ks[0] == "p" {
                        kp.position.x = Float(ks[1])!
                        kp.position.y = Float(ks[2])!
                        kp.position.z = Float(ks[3])!
                    } else if ks[0] == "f" {
                        kp.forward.x = Float(ks[1])!
                        kp.forward.y = Float(ks[2])!
                        kp.forward.z = Float(ks[3])!
                    } else if ks[0] == "u" {
                        kp.up.x = Float(ks[1])!
                        kp.up.y = Float(ks[2])!
                        kp.up.z = Float(ks[3])!
                    } else if ks[0] == "le" {
                        kp.lightEnv = Int(ks[1])!
                    } else if ks[0] == "t" {
                        let t = Float(ks[1])!
                        assert(_distances.count == 0 || t > _distances[_distances.count - 1])
                        _distances.append(t)
                    }
                }
            }
        }

        if _distances.count == _keypoints.count {
            if _distances.count != 0 {
                _totalDistance = _distances[_distances.count - 1]
                _loadedDistances = true
            }
        } else {
            updateDistances()
        }

        return true
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
        for i in 0 ..< _distances.count {
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
        for i in 0 ..< length {
            let steps = 32
            var distance: Float = 0.0
            for j in 0 ..< steps {
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
                            kpprev: inout Int)
    {
        let loopedTime = fmod(time, length)
        kp0 = index(for: loopedTime, t: &t)
        if _loop {
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
                                    pprev: Vector3) -> Vector3
    {
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
        if _keypoints.count == 1 {
            return _keypoints[0].position
        }

        var t: Float = 0
        var kp0 = 0, kp1 = 0, kp2 = 0, kpprev = 0
        getIndices(at: time, t: &t, kp0: &kp0, kp1: &kp1, kp2: &kp2, kpprev: &kpprev)

        let p0 = _keypoints[kp0].position
        let p1 = _keypoints[kp1].position
        let p2 = _keypoints[kp2].position
        let pprev = _keypoints[kpprev].position

        return XCameraController.interpolate(for: t, p0: p0, p1: p1, p2: p2, pprev: pprev)
    }

    private func getForward(at time: Float) -> Vector3 {
        if _keypoints.count == 1 {
            return _keypoints[0].forward
        }

        var t: Float = 0
        var kp0 = 0, kp1 = 0, kp2 = 0, kpprev = 0
        getIndices(at: time, t: &t, kp0: &kp0, kp1: &kp1, kp2: &kp2, kpprev: &kpprev)

        let p0 = _keypoints[kp0].forward
        let p1 = _keypoints[kp1].forward
        let p2 = _keypoints[kp2].forward
        let pprev = _keypoints[kpprev].forward

        return XCameraController.interpolate(for: t, p0: p0, p1: p1, p2: p2, pprev: pprev)
    }

    private func getLightEnv(at time: Float, outA: inout Int, outB: inout Int, outInterp: inout Float) {
        if _keypoints.count == 1 {
            outA = _keypoints[0].lightEnv
            outB = _keypoints[0].lightEnv
            outInterp = 0.0
        }

        let loopedTime = fmod(time, length)

        var t: Float = 0
        let kp0 = index(for: loopedTime, t: &t)
        var kpprev = (kp0 + _keypoints.count - 1) % _keypoints.count

        if !_loop {
            kpprev = max(kp0 - 1, 0)
        }

        let p0 = _keypoints[kp0].lightEnv
        let pprev = _keypoints[kpprev].lightEnv

        outA = pprev
        outB = p0
        outInterp = t
    }
}
