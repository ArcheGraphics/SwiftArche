//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public struct ClassInfo : CustomStringConvertible, Equatable {
    public let classObject: AnyClass
    let className: String
    
    init?(_ classObject: AnyClass?) {
        guard classObject != nil else { return nil }

        let cName = class_getName(classObject)
        self.className = String(cString: cName)
        self.classObject = classObject!
    }

    public var superclassInfo: ClassInfo? {
        let superclassObject: AnyClass? = class_getSuperclass(self.classObject)
        return ClassInfo(superclassObject)
    }

    public var description: String {
        return self.className
    }

    public static func ==(lhs: ClassInfo, rhs: ClassInfo) -> Bool {
        return lhs.className == rhs.className
    }
    
    public static func getSubclass<T:AnyObject>(_ type: T.Type) -> [ClassInfo] {
        let superClassInfo = ClassInfo(type.self)!

        var count = UInt32(0)
        guard let classListPointer = objc_copyClassList(&count) else { return [] }
        return UnsafeBufferPointer(start: classListPointer, count: Int(count))
            .compactMap(ClassInfo.init)
            .filter { $0.superclassInfo == superClassInfo }
    }
}
