import XCTest
@testable import Models

final class ModelsTests: XCTestCase {
    func test_recentSearch_defaultIdIsUnique() {
        let a = RecentSearch(query: "swift")
        let b = RecentSearch(query: "swift")
        XCTAssertNotEqual(a.id, b.id)
    }

    func test_searchError_equatable() {
        XCTAssertEqual(SearchError.network, SearchError.network)
        XCTAssertNotEqual(SearchError.network, SearchError.rateLimited)
    }
}
