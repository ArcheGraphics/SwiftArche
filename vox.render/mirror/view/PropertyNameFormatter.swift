//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

private enum CharacterType {
    case regular
    case wordSeparator
}

class PropertyNameFormatter {
    static func displayName(forPropertyName propertyName: String) -> String {

        if propertyName.count == 0 {
            return ""
        }

        var index = propertyName.startIndex

        func next() -> Character? {
            if index < propertyName.endIndex {
                let value = propertyName[index]
                index = propertyName.index(after: index)
                return value
            } else {
                return nil
            }
        }

        var displayName = ""
        var startNewWord = true

        var prevChar: Character?
        while let char = next() {

            defer {
                prevChar = char
            }

            if isWordSeparator(char) {
                startNewWord = true
                continue
            }

            if isNewWord(char, prev: prevChar) {
                startNewWord = true
            }

            if startNewWord {
                if !displayName.isEmpty {
                    displayName.append(" ")
                }
                displayName.append(char.uppercased())
            } else {
                displayName.append(char)
            }

            startNewWord = false
        }

        return displayName
    }

    static private func isWordSeparator(_ character: Character) -> Bool {
        return character == "_"
    }

    static private func isNewWord(_ character: Character, prev: Character?) -> Bool {

        if character.isUppercase {
            return true
        }

        if character.isNumber && (prev?.isNumber).isNilOrFalse {
            return true
        }

        return false
    }
}

extension Optional where Wrapped == Bool {

    var isNilOrFalse: Bool {
        switch self {
        case .none:
            return true
        case .some(let v):
            return v == false
        }
    }
}
