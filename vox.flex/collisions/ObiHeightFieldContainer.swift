//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct HeightFieldHeader // we need to use the header in the backend, so it must be a struct.
{
    public var firstSample: Int
    public var sampleCount: Int

    public init(firstSample: Int, sampleCount: Int) {
        self.firstSample = firstSample
        self.sampleCount = sampleCount
    }
}
