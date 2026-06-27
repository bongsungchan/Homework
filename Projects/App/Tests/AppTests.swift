import XCTest
import ComposableArchitecture
@testable import App
import Models

@MainActor
final class AppTests: XCTestCase {
    func test_searchSubmitted_pushesSearchResult() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.recentSearchClient.save = { _ in [] }
        }

        await store.send(.search(.queryChanged("tuist"))) {
            $0.search.query = "tuist"
        }
        await store.send(.search(.searchSubmitted))
        await store.receive(.search(.recentSearchesLoaded([])))
        // path 에 searchResult 가 push 됐는지 확인
        XCTAssertEqual(store.state.path.count, 1)
    }
}
