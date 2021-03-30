import XCTest

@testable
import XcKit

final class VersionApproximatelyComparableTests: XCTestCase {

    func testApproximatelyGreaterThanOrEqualTo() {
        XCTAssertFalse(Xcode.Version(0) ~> Xcode.Version(1))
        //
        XCTAssertFalse(Xcode.Version(1, 0) ~> Xcode.Version(1, 1))
        XCTAssertFalse(Xcode.Version(1, 0, 1) ~> Xcode.Version(1, 1))
        XCTAssertFalse(Xcode.Version(1, 0) ~> Xcode.Version(1, 1, 1))
        XCTAssertFalse(Xcode.Version(1, 0, 1) ~> Xcode.Version(1, 1, 1))
        //
        XCTAssertTrue(Xcode.Version(1, 1) ~> Xcode.Version(1, 1))
        XCTAssertTrue(Xcode.Version(1, 1, 1) ~> Xcode.Version(1, 1))
        XCTAssertFalse(Xcode.Version(1, 1) ~> Xcode.Version(1, 1, 1))
        XCTAssertTrue(Xcode.Version(1, 1, 1) ~> Xcode.Version(1, 1, 1))
        //
        XCTAssertTrue(Xcode.Version(1, 2) ~> Xcode.Version(1, 1))
        XCTAssertTrue(Xcode.Version(1, 2, 1) ~> Xcode.Version(1, 1))
        XCTAssertFalse(Xcode.Version(1, 2) ~> Xcode.Version(1, 1, 1))
        XCTAssertFalse(Xcode.Version(1, 2, 1) ~> Xcode.Version(1, 1, 1))
        //
        XCTAssertFalse(Xcode.Version(2) ~> Xcode.Version(1))
    }
}
