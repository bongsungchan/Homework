import XCTest
@testable import Models

final class ModelsTests: XCTestCase {
    func test_recentSearch_defaultIdIsUnique() {
        let a = RecentSearch(keyword: "swift")
        let b = RecentSearch(keyword: "swift")
        XCTAssertNotEqual(a.id, b.id)
    }

    func test_searchError_equatable() {
        XCTAssertEqual(SearchError.network, SearchError.network)
        XCTAssertNotEqual(SearchError.network, SearchError.rateLimited)
    }
}
