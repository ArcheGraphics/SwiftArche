//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class ListenerUpdateFlag: UpdateFlag {
    var listener: ((Int?, AnyObject?) -> Void)?

    override func dispatch(bit: Int?, param: AnyObject?) {
        guard let listener = listener else {
            return
        }
        listener(bit, param)
    }
}