//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Index buffer binding.
public class IndexBufferBinding {
    private var _buffer: MTLBuffer
    private var _format: MTLIndexType

    public var buffer: MTLBuffer {
        get {
            _buffer
        }
    }

    public var format: MTLIndexType {
        get {
            _format
        }
    }

    public init(_ buffer: MTLBuffer, _ format: MTLIndexType) {
        _buffer = buffer
        _format = format
    }
}