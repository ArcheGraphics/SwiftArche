//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

// from https://chromium.googlesource.com/chromium/src/+/master/ui/events/keycodes/keyboard_code_conversion_mac.mm
public enum Keys : UInt16 {
    public typealias RawValue = UInt16
    
    case VKEY_A = 0
    case VKEY_S = 1
    case VKEY_D = 2
    case VKEY_F = 3
    case VKEY_H = 4
    case VKEY_G = 5
    case VKEY_Z = 6
    case VKEY_X = 7
    case VKEY_C = 8
    case VKEY_V = 9
    case VKEY_OEM_3 = 0x0A  // Section key.
    case VKEY_B = 0x0B
    case VKEY_Q = 0x0C
    case VKEY_W = 0x0D
    case VKEY_E = 0x0E
    case VKEY_R = 0x0F
    case VKEY_Y = 0x10
    case VKEY_T = 0x11
    case VKEY_1 = 0x12
    case VKEY_2 = 0x13
    case VKEY_3 = 0x14
    case VKEY_4 = 0x15
    case VKEY_6 = 0x16
    case VKEY_5 = 0x17
    case VKEY_OEM_PLUS = 0x18  // =+
    case VKEY_9 = 0x19
    case VKEY_7 = 0x1A
    case VKEY_OEM_MINUS = 0x1B  // -_
    case VKEY_8 = 0x1C
    case VKEY_0 = 0x1D
    case VKEY_OEM_6 = 0x1E  // ]}
    case VKEY_O = 0x1F
    case VKEY_U = 0x20
    case VKEY_OEM_4 = 0x21  // {[
    case VKEY_I = 0x22
    case VKEY_P = 0x23
    case VKEY_RETURN = 0x24  // Return
    case VKEY_L = 0x25
    case VKEY_J = 0x26
    case VKEY_OEM_7 = 0x27  // '"
    case VKEY_K = 0x28
    case VKEY_OEM_1 = 0x29      // ;:
    case VKEY_OEM_5 = 0x2A      // \|
    case VKEY_OEM_COMMA = 0x2B  // <
    case VKEY_OEM_2 = 0x2C      // /?
    case VKEY_N = 0x2D
    case VKEY_M = 0x2E
    case VKEY_OEM_PERIOD = 0x2F  // .>
    case VKEY_TAB = 0x30
    case VKEY_SPACE = 0x31
//    case VKEY_OEM_3 = 0x32    // `~
    case VKEY_BACK = 0x33     // Backspace
    case VKEY_UNKNOWN = 0x34  // n/a
    case VKEY_ESCAPE = 0x35
    case VKEY_RIGHT_APPS = 0x36     // Right Command
    case VKEY_LEFT_WIN = 0x37     // Left Command
    case VKEY_LEFT_SHIFT = 0x38    // Left Shift
    case VKEY_CAPITAL = 0x39  // Caps Lock
    case VKEY_LEFT_MENU = 0x3A     // Left Option
    case VKEY_LEFT_CONTROL = 0x3B  // Left Ctrl
    case VKEY_RIGHT_SHIFT = 0x3C    // Right Shift
    case VKEY_RIGHT_MENU = 0x3D     // Right Option
    case VKEY_RIGHT_CONTROL = 0x3E  // Right Ctrl
    case VKEY_FN = 0x3F  // fn
    case VKEY_F17 = 0x40
    case VKEY_PAD_DECIMAL = 0x41   // Num Pad .
//    case VKEY_UNKNOWN = 0x42   // n/a
    case VKEY_PAD_MULTIPLY = 0x43  // Num Pad *
//    case VKEY_UNKNOWN = 0x44   // n/a
    case VKEY_PAD_ADD = 0x45       // Num Pad +
//    case VKEY_UNKNOWN = 0x46   // n/a
    case VKEY_PAD_CLEAR = 0x47     // Num Pad Clear
    case VKEY_VOLUME_UP = 0x48
    case VKEY_VOLUME_DOWN = 0x49
    case VKEY_VOLUME_MUTE = 0x4A
    case VKEY_PAD_DIVIDE = 0x4B    // Num Pad /
    case VKEY_PAD_RETURN = 0x4C    // Num Pad Enter
//    case VKEY_UNKNOWN = 0x4D   // n/a
    case VKEY_PAD_SUBTRACT = 0x4E  // Num Pad -
    case VKEY_F18 = 0x4F
    case VKEY_F19 = 0x50
    case VKEY_PAD_PLUS = 0x51  // Num Pad =.
    case VKEY_NUMPAD0 = 0x52
    case VKEY_NUMPAD1 = 0x53
    case VKEY_NUMPAD2 = 0x54
    case VKEY_NUMPAD3 = 0x55
    case VKEY_NUMPAD4 = 0x56
    case VKEY_NUMPAD5 = 0x57
    case VKEY_NUMPAD6 = 0x58
    case VKEY_NUMPAD7 = 0x59
    case VKEY_F20 = 0x5A
    case VKEY_NUMPAD8 = 0x5B
    case VKEY_NUMPAD9 = 0x5C
//    case VKEY_UNKNOWN = 0x5D  // Yen (JIS Keyboard Only)
//    case VKEY_UNKNOWN = 0x5E  // Underscore (JIS Keyboard Only)
//    case VKEY_UNKNOWN = 0x5F  // KeypadComma (JIS Keyboard Only)
    case VKEY_F5 = 0x60
    case VKEY_F6 = 0x61
    case VKEY_F7 = 0x62
    case VKEY_F3 = 0x63
    case VKEY_F8 = 0x64
    case VKEY_F9 = 0x65
//    case VKEY_UNKNOWN = 0x66  // Eisu (JIS Keyboard Only)
    case VKEY_F11 = 0x67
//    case VKEY_UNKNOWN = 0x68  // Kana (JIS Keyboard Only)
    case VKEY_F13 = 0x69
    case VKEY_F16 = 0x6A
    case VKEY_F14 = 0x6B
//    case VKEY_UNKNOWN = 0x6C  // n/a
    case VKEY_F10 = 0x6D
    case VKEY_APPS = 0x6E  // Context Menu key
    case VKEY_F12 = 0x6F
//    case VKEY_UNKNOWN = 0x70  // n/a
    case VKEY_F15 = 0x71
    case VKEY_INSERT = 0x72  // Help
    case VKEY_HOME = 0x73    // Home
    case VKEY_PRIOR = 0x74   // Page Up
    case VKEY_DELETE = 0x75  // Forward Delete
    case VKEY_F4 = 0x76
    case VKEY_END = 0x77  // End
    case VKEY_F2 = 0x78
    case VKEY_NEXT = 0x79  // Page Down
    case VKEY_F1 = 0x7A
    case VKEY_LEFT = 0x7B    // Left Arrow
    case VKEY_RIGHT = 0x7C   // Right Arrow
    case VKEY_DOWN = 0x7D    // Down Arrow
    case VKEY_UP = 0x7E      // Up Arrow
//    case VKEY_UNKNOWN = 0x7F  // n/a
}
