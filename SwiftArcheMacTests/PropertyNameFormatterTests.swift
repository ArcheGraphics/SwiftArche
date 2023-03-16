//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_render

final class PropertyNameFormatterTests: XCTestCase {
    func testPropertyNameFormatter() {
        func test(_ input: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
            let output = PropertyNameFormatter.displayName(forPropertyName: input)
            XCTAssertEqual(output, expected, file: file, line: line)
        }
        
        test("name", "Name")
        test("_name", "Name")
        test("myProperty", "My Property")
        test("my_property", "My Property")
        test("my_property2", "My Property 2")
        test("my_property24", "My Property 24")
    }
}
