import XCTest
@testable import TSSS_JSONRPCServer

class TSSS_JSONRPCServerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(TSSS_JSONRPCServer().text, "Hello, World!")
    }


    static var allTests : [(String, (TSSS_JSONRPCServerTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
