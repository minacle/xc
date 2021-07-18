import XCTest

@testable
import XcKit

final class HashTests: XCTestCase {

    func testXcode() {
        let xcodes: [Xcode] = [
            .init(
                name: "Xcode",
                path: "/Application/Xcode.app",
                version: .init(12, 5, 0),
                build: .init(12, .e, 262),
                licenseType: .release),
            .init(
                name: "Xcode",
                path: "/Application/Xcode.app",
                version: .init(12, 5, 0),
                build: .init(12, .e, 262),
                licenseType: .beta),
            .init(
                name: "Xcode",
                path: "/Application/Xcode.app",
                version: .init(12, 5, 0),
                build: .init(12, .e, 262),
                licenseType: .gm),
        ]
        XCTAssertNotEqual(xcodes[0].hashValue, xcodes[1].hashValue)
        XCTAssertEqual(xcodes[0].hashValue, xcodes[2].hashValue)
    }
}
