import XCTest
import ComposableArchitecture
@testable import Search
import Models

@MainActor
final class SearchFeatureTests: XCTestCase {
    func test_onAppear_loadsRecentSearches() async {
        let items = [RecentSearch(keyword: "swift")]
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.load = { items }
        }

        await store.send(.onAppear)
        await store.receive(.recentSearchesLoaded(items)) {
            $0.recentSearches = items
        }
    }

    func test_queryChanged_filtersSuggestions() async {
        let items = [RecentSearch(keyword: "swift"), RecentSearch(keyword: "swiftui")]
        var state = SearchFeature.State()
        state.recentSearches = items
        let store = TestStore(initialState: state) {
            SearchFeature()
        }

        await store.send(.queryChanged("swiftui")) {
            $0.query = "swiftui"
            $0.suggestions = [items[1]]
        }
    }

    func test_searchSubmitted_savesKeyword() async {
        let saved = [RecentSearch(keyword: "tuist")]
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.save = { _ in saved }
        }

        await store.send(.queryChanged("tuist")) {
            $0.query = "tuist"
        }
        await store.send(.searchSubmitted)
        await store.receive(.recentSearchesLoaded(saved)) {
            $0.recentSearches = saved
        }
    }
}
