//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/**
 * Defines values that specify the buttons on a pointer device.
 * Refer to the W3C standards:
 * (https://www.w3.org/TR/uievents/#dom-mouseevent-button)
 * (https://www.w3.org/TR/uievents/#dom-mouseevent-buttons)
 * Refer to Microsoft's documentation.(https://docs.microsoft.com/en-us/dotnet/api/system.windows.input.mousebutton?view=windowsdesktop-6.0)
 */
public enum PointerButton: Int {
    /** No button. */
    case None = 0x0
    /** Indicate the primary pointer of the device (in general, the left button or the only button on single-button devices, used to activate a user interface control or select text) or the un-initialized value. */
    case Primary = 0x1
    /** Indicate the secondary pointer (in general, the right button, often used to display a context menu). */
    case Secondary = 0x2
    /** Indicate the auxiliary pointer (in general, the middle button, often combined with a mouse wheel). */
    case Auxiliary = 0x4
    /** Indicate the X1 (back) pointer. */
    case XButton1 = 0x8
    /** Indicate the X2 (forward) pointer. */
    case XButton2 = 0x10
    /** Indicate the X3 pointer. */
    case XButton3 = 0x20
    /** Indicate the X4 pointer. */
    case XButton4 = 0x40
    /** Indicate the X5 pointer. */
    case XButton5 = 0x80
    /** Indicate the X6 pointer. */
    case XButton6 = 0x100
    /** Indicate the X7 pointer. */
    case XButton7 = 0x200
    /** Indicate the X8 pointer. */
    case XButton8 = 0x400
}

let _pointerDec2BinMap = [
    PointerButton.Primary,
    PointerButton.Auxiliary,
    PointerButton.Secondary,
    PointerButton.XButton1,
    PointerButton.XButton2,
    PointerButton.XButton3,
    PointerButton.XButton4,
    PointerButton.XButton5,
    PointerButton.XButton6,
    PointerButton.XButton7,
    PointerButton.XButton8
]
