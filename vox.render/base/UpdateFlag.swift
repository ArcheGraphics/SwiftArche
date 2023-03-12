//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Used to update tags.
public class UpdateFlag {
    var _flagManagers: [UpdateFlagManager] = []

    func destroy() {
        _removeFromManagers()
        _flagManagers = []
    }

    /// - Parameters: Dispatch.
    ///   - bit: Bit
    ///   - param: Parameter
    public func dispatch(bit: Int?, param: AnyObject?) {
    }

    private func _removeFromManagers() {
        for flagManager in _flagManagers {
            _ = removeFromArray(array: &flagManager._updateFlags, item: self)
        }
    }
}
