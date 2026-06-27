import XCTest
@testable import Networking
import Models

final class NetworkingTests: XCTestCase {
    func test_repositoryClient_liveInitializes() {
        let client = RepositoryClient.live()
        XCTAssertNotNil(client.searchRepositories)
    }
}
