//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class GLTFUtil {
    static func convert<T>(_ accessor: GLTFAccessor, out: inout [T]) {
        if let bufferView = accessor.bufferView,
           let data = bufferView.buffer.data {
            let offset = accessor.offset + bufferView.offset
            (data as NSData).getBytes(&out,
                    range: NSRange(location: offset,
                            length: MemoryLayout<T>.stride * accessor.count))

        }
    }
}
