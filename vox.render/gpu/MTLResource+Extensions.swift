//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public extension MTLResource {
    var isAccessibleOnCPU: Bool {
        #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(tvOS)
        return storageMode == .shared
        #elseif os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        return storageMode == .managed || storageMode == .shared
        #endif
    }
}

extension MTLResourceUsage {
    public static var readWrite = MTLResourceUsage(rawValue: (MTLResourceUsage.read.rawValue | MTLResourceUsage.write.rawValue))
}
