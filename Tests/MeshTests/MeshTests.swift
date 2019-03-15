import XCTest
@testable import Mesh

final class MeshTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Mesh().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
