import Combine
import XCTest

@testable
import XcKit

final class CombineTest: XCTestCase {

    private var xcodes: Set<Xcode>? {
        didSet {
            self.xcodesDidSetHandler?()
        }
    }

    private var xcodesDidSetHandler: (() -> Void)?

    override func setUp() {
        super.setUp()
        self.xcodes = nil
    }

    override func tearDown() {
        super.tearDown()
        self.xcodesDidSetHandler = nil
    }

    func testSink() {
        let xc = Xc()
        let publisher = xc.reload()
        let dsema = DispatchSemaphore(value: 0)
        let subscriber =
            publisher
            .sink {
                self.xcodes = $0
                dsema.signal()
            }
        switch dsema.wait(wallTimeout: .now() + 10) {
        case .success:
            XCTAssertNotNil(self.xcodes)
        case .timedOut:
            subscriber.cancel()
            XCTFail("Timed out")
        }
    }

    func testAssign() {
        let xc = Xc()
        let publisher = xc.reload()
        let dsema = DispatchSemaphore(value: 0)
        self.xcodesDidSetHandler = {
            dsema.signal()
        }
        let subscriber =
            publisher
            .map({Optional($0)})
            .assign(to: \.xcodes, on: self)
        switch dsema.wait(wallTimeout: .now() + 10) {
        case .success:
            XCTAssertNotNil(self.xcodes)
        case .timedOut:
            subscriber.cancel()
            XCTFail("Timed out")
        }
    }
}
