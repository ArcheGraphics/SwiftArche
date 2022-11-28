//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// High-performance unordered array, delete uses exchange method to improve performance, internal capacity only increases.
class DisorderedArray<T> {
    var _elements: [T?] = []

    var count: Int = 0

    init(_ count: Int = 0) {
        _elements = [T?](repeating: nil, count: count)
    }

    func add(_ element: T) {
        if (count == _elements.count) {
            _elements.append(element)
        } else {
            _elements[count] = element
        }
        count += 1
    }

    func get(_ index: Int) -> T? {
        if (index >= count) {
            fatalError("Index is out of range.")
        }
        return _elements[index]
    }

    /// The replaced item is used to reset its index.
    /// - Parameter index: index
    /// - Returns: The replaced item is used to reset its index.
    func deleteByIndex(_ index: Int) -> T? {
        var end: T? = nil
        let lastIndex = count - 1
        if (index != lastIndex) {
            end = _elements[lastIndex]
            _elements[index] = end!
        }
        count -= 1
        return end
    }

    func garbageCollection() {
        _elements.removeLast(count - _elements.count)
    }
}

extension DisorderedArray where T: AnyObject {
    func delete(_ element: T) {
        _elements.removeAll { e in
            if e == nil {
                return false
            } else {
                return e! === element
            }
        }
    }
}

extension DisorderedArray where T == Int {
    func delete(_ element: T) {
        _elements.removeAll { e in
            if e == nil {
                return false
            } else {
                return e! == element
            }
        }
    }
}
