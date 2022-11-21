//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Store the data for Animator playback.
class AnimatorController {
    private var _updateFlagManager: UpdateFlagManager = UpdateFlagManager()
    private var _layers: [AnimatorControllerLayer] = []
    private var _layersMap: [String: AnimatorControllerLayer] = [:]

    /// The layers in the controller.
    var layers: [AnimatorControllerLayer] {
        get {
            _layers
        }
    }

    /// Get the layer by name.
    /// - Parameter name: The layer's name.
    /// - Returns: The Layer
    func findLayerByName(_ name: String) -> AnimatorControllerLayer? {
        _layersMap[name]
    }

    /// Add a layer to the controller.
    /// - Parameter layer: The layer to add
    func addLayer(_ layer: AnimatorControllerLayer) {
        _layers.append(layer)
        _layersMap[layer.name] = layer
        _distributeUpdateFlag()
    }

    /// Remove a layer from the controller.
    /// - Parameter layerIndex: The index of the AnimatorLayer
    func removeLayer(_ layerIndex: Int) {
        let theLayer = layers[layerIndex]
        _layers.remove(at: layerIndex)
        _layersMap.removeValue(forKey: theLayer.name)
        _distributeUpdateFlag()
    }

    /// Clear layers.
    func clearLayers() {
        _layers = []
        _layersMap = [:]
        _distributeUpdateFlag()
    }

    internal func _registerChangeFlag() -> BoolUpdateFlag {
        let flag = BoolUpdateFlag()
        _updateFlagManager.addFlag(flag: flag)
        return flag
    }

    private func _distributeUpdateFlag() {
        _updateFlagManager.dispatch()
    }
}
