//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// An allocation of device memory. different buffer allocations,
/// with different offset and size, may come from the same device buffer
public struct BufferAllocation {
    private var _buffer: MTLBuffer
    private var _baseOffset: Int
    private var _size: Int

    public var isEmpty: Bool {
        get {
            _size == 0
        }
    }

    public var size: Int {
        get {
            _size
        }
    }

    public var offset: Int {
        get {
            _baseOffset
        }
    }

    public var buffer: MTLBuffer {
        get {
            _buffer
        }
    }

    public init(_ buffer: MTLBuffer, _ size: Int, _ offset: Int) {
        _buffer = buffer
        _size = size
        _baseOffset = offset
    }

    public func update<T>(_ value: T, offset: Int = 0) {
        if MemoryLayout<T>.size + offset < _size {
            withUnsafePointer(to: value) {
                _buffer.contents().advanced(by: _baseOffset + offset).copyMemory(from: $0, byteCount: MemoryLayout<T>.stride)
            }
        }
    }
}

//// Helper class which handles multiple allocation from the same underlying device buffer.
public class BufferBlock {
    private var _buffer: MTLBuffer
    // Memory alignment, it may change according to the usage
    private var _alignment: Int = 256
    // Current offset, it increases on every allocation
    private var _offset: Int = 0

    public var size: Int {
        get {
            _buffer.length
        }
    }

    public init(_ device: MTLDevice, size: Int, options: MTLResourceOptions) {
        guard let buffer = device.makeBuffer(length: size, options: options) else {
            fatalError("Failed to create MTLBuffer.")
        }
        _buffer = buffer
    }

    /// An usable view on a portion of the underlying buffer
    public func allocate(_ size: Int) -> BufferAllocation? {
        let aligned_offset = (_offset + _alignment - 1) & ~(_alignment - 1)

        if (aligned_offset + size > _buffer.length) {
            // No more space available from the underlying buffer, return empty allocation
            return nil
        }
        // Move the current offset and return an allocation
        _offset = aligned_offset + size
        return BufferAllocation(_buffer, size, aligned_offset)
    }

    public func reset() {
        _offset = 0
    }
}


/// A pool of buffer blocks for a specific usage.
/// It may contain inactive blocks that can be recycled.
///
/// BufferPool is a linear allocator for buffer chunks, it gives you a view of the size you want.
/// A BufferBlock is the corresponding VkBuffer and you can get smaller offsets inside it.
/// Since a shader cannot specify dynamic UBOs, it has to be done from the code
/// (set_resource_dynamic).
///
/// When a new frame starts, buffer blocks are returned: the offset is reset and contents are
/// overwritten. The minimum allocation size is 256 kb, if you ask for more you get a dedicated
/// buffer allocation.
///
/// We re-use descriptor sets: we only need one for the corresponding buffer infos (and we only
/// have one VkBuffer per BufferBlock), then it is bound and we use dynamic offsets.
public class BufferPool {
    private var _options: MTLResourceOptions
    private var _device: MTLDevice
    /// List of blocks requested
    private var _buffer_blocks: [BufferBlock] = []
    /// Minimum size of the blocks
    private var _block_size: Int = 0
    /// Numbers of active blocks from the start of buffer_blocks
    private var _active_buffer_block_count: Int = 0

    public init(_ device: MTLDevice, _ block_size: Int, _ options: MTLResourceOptions = []) {
        _device = device
        _block_size = block_size
        _options = options
    }

    public func requestBufferBlock(minimum_size: Int) -> BufferBlock {
        for i in _active_buffer_block_count..<_buffer_blocks.count {
            if _buffer_blocks[i].size >= minimum_size {
                _active_buffer_block_count += 1
                return _buffer_blocks[i]
            }
        }

        // Create a new block, store and return it
        _buffer_blocks.append(BufferBlock(_device, size: max(_block_size, minimum_size), options: _options))
        let block = _buffer_blocks[_active_buffer_block_count]
        _active_buffer_block_count += 1
        return block
    }

    public func reset() {
        for buffer_block in _buffer_blocks {
            buffer_block.reset()
        }
        _active_buffer_block_count = 0
    }
}