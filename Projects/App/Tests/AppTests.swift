import XCTest
import ComposableArchitecture
@testable import App
import Models

@MainActor
final class AppTests: XCTestCase {
    func test_searchSubmitted_pushesSearchResult() async {
        var state = AppFeature.State()
        state.search.query = "tuist"

        let store = TestStore(initialState: state) {
            AppFeature()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        store.exhaustivity = .off

        await store.send(.search(.searchSubmitted))
        await store.skipReceivedActions()

        XCTAssertEqual(store.state.path.count, 1)
    }
}
