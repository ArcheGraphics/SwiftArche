//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// BlendShape.
public class BlendShape {
    /// Name of BlendShape.
    public var name: String

    var _useBlendShapeNormal: Bool = true
    var _useBlendShapeTangent: Bool = true
    var _layoutChangeManager: UpdateFlagManager = UpdateFlagManager()

    private var _dataChangeManager: UpdateFlagManager = UpdateFlagManager()
    private var _frames: [BlendShapeFrame] = []

    /// Frames of BlendShape.
    public var frames: [BlendShapeFrame] {
        get {
            _frames
        }
    }

    /// Create a BlendShape.
    /// - Parameter name: BlendShape name.
    public init(_ name: String) {
        self.name = name
    }

    /// Add a BlendShapeFrame by weight, deltaPositions, deltaNormals and deltaTangents.
    /// - Parameters:
    ///   - weight: Weight of BlendShapeFrame
    ///   - deltaPositions: Delta positions for the frame being added
    ///   - deltaNormals: Delta normals for the frame being added
    ///   - deltaTangents: Delta tangents for the frame being added
    /// - Returns:
    public func addFrame(weight: Float,
                         deltaPositions: [Vector3],
                         deltaNormals: [Vector3]? = nil,
                         deltaTangents: [Vector3]? = nil) -> BlendShapeFrame {
        let frame = BlendShapeFrame(weight, deltaPositions, deltaNormals, deltaTangents)
        _addFrame(frame)
        return frame
    }

    /// Add a BlendShapeFrame.
    /// - Parameter frame: The BlendShapeFrame.
    public func addFrame(_ frame: BlendShapeFrame) {
        _addFrame(frame)
    }

    public func clearFrames() {
        _frames = []
        _updateUseNormalAndTangent(true, true)
        _dataChangeManager.dispatch()
    }

    func _addDataDirtyFlag(flag: UpdateFlag) {
        _dataChangeManager.addFlag(flag: flag)
    }

    func _createSubDataDirtyFlag() -> BoolUpdateFlag {
        let flag = BoolUpdateFlag()
        _dataChangeManager.addFlag(flag: flag)
        return flag
    }

    private func _addFrame(_ frame: BlendShapeFrame) {
        let frameCount = _frames.count
        if (frameCount > 0 && frame.deltaPositions.count != _frames[frameCount - 1].deltaPositions.count) {
            fatalError("Frame's deltaPositions length must same with before frame deltaPositions length.")
        }
        _frames.append(frame)

        _updateUseNormalAndTangent(frame.deltaNormals != nil, frame.deltaTangents != nil)
        _dataChangeManager.dispatch()
    }

    private func _updateUseNormalAndTangent(_ useNormal: Bool, _ useTangent: Bool) {
        let useBlendShapeNormal = _useBlendShapeNormal && useNormal
        let useBlendShapeTangent = _useBlendShapeTangent && useTangent
        if (_useBlendShapeNormal != useBlendShapeNormal || _useBlendShapeTangent != useBlendShapeTangent) {
            _useBlendShapeNormal = useBlendShapeNormal
            _useBlendShapeTangent = useBlendShapeTangent
            _layoutChangeManager.dispatch(type: 0, param: self)
        }
    }
}