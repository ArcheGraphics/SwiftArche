//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Used to update tags.
class UpdateFlag {
    var _flagManagers: [UpdateFlagManager] = []

    /// - Parameters: Dispatch.
    ///   - bit: Bit
    ///   - param: Parameter
    func dispatch(bit: Int?, param: AnyObject?) {
    }

    func clearFromManagers() {
        _removeFromManagers()
        _flagManagers.removeAll()
    }

    func destroy() {
        _removeFromManagers()
        _flagManagers = []
    }

    private func _removeFromManagers() {
        for flagManager in _flagManagers {
            _ = removeFromArray(array: &flagManager._updateFlags, item: self)
        }
    }
}
