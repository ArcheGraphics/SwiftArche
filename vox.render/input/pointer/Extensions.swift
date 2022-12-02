//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import vox_math

#if os(iOS)

#else
extension NSEvent {
    public func screenPoint(_ canvas: Canvas)->Vector2 {
        var mousePoint = canvas.convert(locationInWindow, to: nil)
        mousePoint = NSMakePoint(mousePoint.x, canvas.bounds.size.height - mousePoint.y)
        return Vector2(Float(mousePoint.x), Float(mousePoint.y))
    }
}
#endif
