//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class ListenerUpdateFlag: UpdateFlag {
    public var listener: ((Int?, AnyObject?) -> Void)?
    
    public override init() {}

    public override func dispatch(bit: Int?, param: AnyObject?) {
        guard let listener = listener else {
            return
        }
        listener(bit, param)
    }
}
