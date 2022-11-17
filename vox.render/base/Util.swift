//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Fastly remove an element from array.
/// - Parameters:
///   - array: Array
///   - item: Element
/// - Returns: Whether remove successful
func removeFromArray<T: AnyObject>(array: inout [T], item: T) -> Bool {
    let index = array.firstIndex { (v: T) in
        v === item
    }
    if (index == nil) {
        return false
    }
    let last = array.count - 1
    if (index! != last) {
        let end = array[last]
        array[index!] = end
    }
    array.removeLast()
    return true
}
