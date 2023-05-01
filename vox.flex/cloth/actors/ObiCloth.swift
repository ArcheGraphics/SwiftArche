//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiCloth: ObiClothBase, IVolumeConstraintsUser, ITetherConstraintsUser {
    var m_ClothBlueprint: ObiClothBlueprint?

    // volume constraints:
    var _volumeConstraintsEnabled = true
    var _compressionCompliance: Float = 0
    var _pressure: Float = 1

    // tethers
    var _tetherConstraintsEnabled: Bool = true
    var _tetherCompliance: Float = 0
    var _tetherScale: Float = 1

    public var volumeConstraintsEnabled: Bool {
        get {
            _volumeConstraintsEnabled
        }
        set {
            _volumeConstraintsEnabled = newValue
        }
    }

    public var compressionCompliance: Float {
        get {
            _compressionCompliance
        }
        set {
            _compressionCompliance = newValue
        }
    }

    public var pressure: Float {
        get {
            _pressure
        }
        set {
            _pressure = newValue
        }
    }

    public var tetherConstraintsEnabled: Bool {
        get {
            _tetherConstraintsEnabled
        }
        set {
            _tetherConstraintsEnabled = newValue
        }
    }

    public var tetherCompliance: Float {
        get {
            _tetherCompliance
        }
        set {
            _tetherCompliance = newValue
        }
    }

    public var tetherScale: Float {
        get {
            _tetherScale
        }
        set {
            _tetherScale = newValue
        }
    }

    private func SetupRuntimeConstraints() {}
}
