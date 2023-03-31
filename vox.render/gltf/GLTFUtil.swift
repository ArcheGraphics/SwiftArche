//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class GLTFUtil {
    static func convert<T>(_ accessor: GLTFAccessor, out: inout [T]) {
        let bytesPerComponent = GLTFBytesPerComponentForComponentType(accessor.componentType)
        let componentCount = GLTFComponentCountForDimension(accessor.dimension)
        let elementSize = Int(bytesPerComponent * componentCount)
        if let data = GLTFSCNPackedDataForAccessor(accessor) {
            (data as NSData).getBytes(&out, range: NSRange(location: 0, length: elementSize * accessor.count))
        }
    }
}
