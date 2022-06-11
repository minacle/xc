import XCTest

@testable
import XcKit

final class ConcurrencyTests: XCTestCase {

    func testReload() async throws {
#if canImport(_Concurrency)
        let xc = Xc()
        let xcodes = await xc.reload()
        XCTAssertEqual(xcodes, xc.xcodes)
#else
        try XCTSkip()
#endif
    }
}
