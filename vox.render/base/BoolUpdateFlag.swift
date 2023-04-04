//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class BoolUpdateFlag: UpdateFlag {
    public var flag: Bool = true

    override public func dispatch(bit _: Int?, param _: AnyObject?) {
        flag = true
    }
}
