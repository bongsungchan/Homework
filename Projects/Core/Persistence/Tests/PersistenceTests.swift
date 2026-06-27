import XCTest
@testable import Persistence
import Models

final class PersistenceTests: XCTestCase {
    func test_recentSearchClient_liveInitializes() {
        let client = RecentSearchClient.live()
        XCTAssertNotNil(client.load)
    }
}
