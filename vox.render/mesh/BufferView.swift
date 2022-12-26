//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// A wrapper around MTLBuffer which provides type safe access and assignment to the underlying MTLBuffer's contents.
public struct BufferView {
    /// The underlying MTLBuffer.
    private let _buffer: MTLBuffer
    /// The number of Elements the buffer can hold.
    private let _count: Int
    private let _stride: Int

    public var stride: Int {
        get {
            _stride
        }
    }

    public var count: Int {
        get {
            _count
        }
    }

    public var buffer: MTLBuffer {
        get {
            _buffer
        }
    }

    /// Initializes the buffer with zeros, the buffer is given an appropriate length based on the provided element count.
    public init(device: MTLDevice, count: Int, stride: Int, label: String? = nil, options: MTLResourceOptions = []) {
        guard let buffer = device.makeBuffer(length: stride * count, options: options) else {
            fatalError("Failed to create MTLBuffer.")
        }
        _buffer = buffer
        _buffer.label = label
        _count = count
        _stride = stride
    }

    /// Initializes the buffer with the contents of the provided array.
    public init<Element>(device: MTLDevice, array: [Element], options: MTLResourceOptions = .storageModeShared) {
        guard let buffer = device.makeBuffer(bytes: array, length: MemoryLayout<Element>.stride * array.count, options: options) else {
            fatalError("Failed to create MTLBuffer")
        }
        _buffer = buffer
        _count = array.count
        _stride = MemoryLayout<Element>.stride
    }

    /// Replaces the buffer's memory at the specified element index with the provided value.
    public func assign<Element>(_ value: Element, at index: Int = 0) {
        precondition(index <= _count - 1, "Index \(index) is greater than maximum allowable index of \(_count - 1) for this buffer.")
        withUnsafePointer(to: value) {
            _buffer.contents().advanced(by: index * stride).copyMemory(from: $0, byteCount: stride)
        }
    }

    /// Replaces the buffer's memory with the values in the array.
    public func assign<Element>(with array: [Element]) {
        let byteCount = array.count * stride
        precondition(byteCount == _buffer.length, "Mismatch between the byte count of the array's contents and the MTLBuffer length.")
        _buffer.contents().copyMemory(from: array, byteCount: byteCount)
    }

    /// Returns a copy of the value at the specified element index in the buffer.
    public subscript<Element>(index: Int) -> Element {
        precondition(stride * index <= _buffer.length - stride, "This buffer is not large enough to have an element at the index: \(index)")
        return _buffer.contents().advanced(by: index * stride).load(as: Element.self)
    }
}
