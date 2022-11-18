//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class BoolUpdateFlag: UpdateFlag {
    public var flag: Bool = true

    public override func dispatch(bit: Int?, param: AnyObject?) {
        flag = true
    }
}