import XCTest

@testable
import XcKit

final class CustomStringConvertibleTests: XCTestCase {

    func testBuild() {
        XCTAssertEqual(Xcode.Build(0).description, "1A1")
        XCTAssertEqual(Xcode.Build(2, .a, 30, .f).description, "2A30f")
        XCTAssertEqual(Xcode.Build(3, .c, 500).debugDescription, "3C500")
        XCTAssertEqual(Xcode.Build(4, .d, 5050, .g).debugDescription, "4D5050g")
    }

    func testVersion() {
        XCTAssertEqual(Xcode.Version().description, "0.0")
        XCTAssertEqual(Xcode.Version().debugDescription, "0.0")
        XCTAssertEqual(Xcode.Version(3, 1, 0).description, "3.1")
        XCTAssertEqual(Xcode.Version(4, 2, 1).description, "4.2.1")
        XCTAssertEqual(Xcode.Version(5, 0, 0).debugDescription, "5.0.0")
        XCTAssertEqual(Xcode.Version(6, 1).debugDescription, "6.1")
    }
}
