//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class UpdateFlagManager {
    var _updateFlags: [UpdateFlag] = []

    /// Add a UpdateFlag.
    /// - Parameter flag: The UpdateFlag.
    func addFlag(flag: UpdateFlag) {
        _updateFlags.append(flag);
        flag._flagManagers.append(self);
    }

    /// Remove a UpdateFlag.
    /// - Parameter flag: The UpdateFlag.
    func removeFlag(flag: UpdateFlag) {
        let success = removeFromArray(array: &_updateFlags, item: flag);
        if (success) {
            _ = removeFromArray(array: &flag._flagManagers, item: self);
        }
    }

    /// Dispatch a event.
    /// - Parameters:
    ///   - type: Event type, usually in the form of enumeration
    ///   - param: Event param
    func dispatch(type: Int?, param: AnyObject?) {
        for item in _updateFlags {
            item.dispatch(bit: type, param: param)
        }
    }
}
