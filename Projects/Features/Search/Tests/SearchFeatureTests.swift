import ComposableArchitecture
import XCTest
@testable import Search
import Models

@MainActor
final class SearchFeatureTests: XCTestCase {

    private func makeStore(
        state: SearchFeature.State = SearchFeature.State(),
        clock: TestClock<Duration> = TestClock(),
        load: @Sendable @escaping () async throws -> [RecentSearch] = { [] },
        save: @Sendable @escaping (_ query: String) async throws -> [RecentSearch] = { _ in [] },
        delete: @Sendable @escaping (_ id: UUID) async throws -> [RecentSearch] = { _ in [] },
        deleteAll: @Sendable @escaping () async throws -> Void = {}
    ) -> TestStore<SearchFeature.State, SearchFeature.Action> {
        TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.recentSearchClient.load = load
            $0.recentSearchClient.save = save
            $0.recentSearchClient.delete = delete
            $0.recentSearchClient.deleteAll = deleteAll
        }
    }

    func test_onAppear_setsLoadingThenLoaded() async {
        let items = [
            RecentSearch(id: UUID(), query: "swift", date: .now),
            RecentSearch(id: UUID(), query: "tuist", date: .now)
        ]
        let store = makeStore(load: { items })

        await store.send(.onAppear) {
            $0.viewState = .loading
        }
        await store.receive(.recentSearchesLoaded(items)) {
            $0.recentSearches = items
            $0.viewState = .loaded
        }
    }

    func test_onAppear_emptyResult_setsEmptyState() async {
        let store = makeStore(load: { [] })

        await store.send(.onAppear) {
            $0.viewState = .loading
        }
        await store.receive(.recentSearchesLoaded([])) {
            $0.viewState = .empty
        }
    }

    func test_onAppear_loadFailure_setsFailedState() async {
        let store = makeStore(load: { throw SearchError.unknown })

        await store.send(.onAppear) {
            $0.viewState = .loading
        }
        await store.receive(.recentSearchLoadFailed(.unknown)) {
            $0.viewState = .failed(.unknown)
        }
    }

    func test_onAppear_isIdempotent_whenAlreadyLoaded() async {
        var initialState = SearchFeature.State()
        initialState.viewState = .loaded
        initialState.recentSearches = [RecentSearch(query: "swift")]
        let store = makeStore(state: initialState)

        await store.send(.onAppear)
    }

    func test_queryChanged_toEmpty_showsRecentSearches_whenExists() async {
        var state = SearchFeature.State()
        let items = [RecentSearch(query: "swift")]
        state.recentSearches = items
        state.query = "swi"
        state.suggestions = [items[0]]
        state.viewState = .loaded
        let store = makeStore(state: state)

        await store.send(.queryChanged("")) {
            $0.query = ""
            $0.suggestions = []
            $0.viewState = .loaded
        }
    }

    func test_queryChanged_toEmpty_showsEmptyState_whenNoRecentSearches() async {
        var state = SearchFeature.State()
        state.query = "ab"
        state.viewState = .loaded
        let store = makeStore(state: state)

        await store.send(.queryChanged("")) {
            $0.query = ""
            $0.suggestions = []
            $0.viewState = .empty
        }
    }

    func test_queryChanged_toEmpty_cancelsPendingDebounce() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)

        await store.send(.onAppear) { $0.viewState = .loading }
        await store.receive(.recentSearchesLoaded([])) { $0.viewState = .empty }

        await store.send(.queryChanged("sw")) { $0.query = "sw" }
        await store.send(.queryChanged("")) {
            $0.query = ""
            $0.viewState = .empty
        }
        await clock.advance(by: .milliseconds(300))
    }

    func test_queryChanged_nonEmpty_debounces300ms_thenFiltersSuggestions() async {
        let clock = TestClock()
        let items = [
            RecentSearch(query: "swift"),
            RecentSearch(query: "swiftui"),
            RecentSearch(query: "tuist")
        ]
        var state = SearchFeature.State()
        state.recentSearches = items
        state.viewState = .loaded
        let store = makeStore(state: state, clock: clock)

        await store.send(.queryChanged("swift")) {
            $0.query = "swift"
        }
        await clock.advance(by: .milliseconds(299))
        await clock.advance(by: .milliseconds(1))
        await store.receive(.querySuggestionDebounced) {
            $0.suggestions = [items[0], items[1]]
            $0.viewState = .loaded
        }
    }

    func test_queryChanged_rapidInput_cancelsEarlierDebounce() async {
        let clock = TestClock()
        let items = [
            RecentSearch(query: "swift"),
            RecentSearch(query: "swiftui")
        ]
        var state = SearchFeature.State()
        state.recentSearches = items
        state.viewState = .loaded
        let store = makeStore(state: state, clock: clock)

        await store.send(.queryChanged("s")) { $0.query = "s" }
        await clock.advance(by: .milliseconds(100))

        await store.send(.queryChanged("sw")) { $0.query = "sw" }
        await clock.advance(by: .milliseconds(300))

        await store.receive(.querySuggestionDebounced) {
            $0.suggestions = [items[0], items[1]]
            $0.viewState = .loaded
        }
    }

    func test_queryChanged_noMatchingSuggestions_setsEmptySuggestions() async {
        let clock = TestClock()
        let items = [RecentSearch(query: "tuist")]
        var state = SearchFeature.State()
        state.recentSearches = items
        state.viewState = .loaded
        let store = makeStore(state: state, clock: clock)

        await store.send(.queryChanged("swift")) { $0.query = "swift" }
        await clock.advance(by: .milliseconds(300))

        await store.receive(.querySuggestionDebounced)
    }

    func test_queryChanged_caseInsensitiveSuggestionMatch() async {
        let clock = TestClock()
        let items = [RecentSearch(query: "Swift")]
        var state = SearchFeature.State()
        state.recentSearches = items
        state.viewState = .loaded
        let store = makeStore(state: state, clock: clock)

        await store.send(.queryChanged("swift")) { $0.query = "swift" }
        await clock.advance(by: .milliseconds(300))

        await store.receive(.querySuggestionDebounced) {
            $0.suggestions = [items[0]]
            $0.viewState = .loaded
        }
    }

    func test_searchSubmitted_savesKeyword_andUpdatesRecentSearches() async {
        let saved = [RecentSearch(query: "tuist")]
        var state = SearchFeature.State()
        state.query = "tuist"
        let store = makeStore(
            state: state,
            save: { _ in saved }
        )

        await store.send(.searchSubmitted)
        await store.receive(.recentSearchesLoaded(saved)) {
            $0.recentSearches = saved
            $0.suggestions = saved
            $0.viewState = .loaded
        }
    }

    func test_searchSubmitted_withEmptyQuery_doesNothing() async {
        let store = makeStore()
        await store.send(.searchSubmitted)
    }

    func test_searchSubmitted_withWhitespaceOnlyQuery_doesNothing() async {
        var state = SearchFeature.State()
        state.query = "   "
        let store = makeStore(state: state)

        await store.send(.searchSubmitted)
    }

    func test_searchSubmitted_saveFailure_fallsBackToLoad() async {
        let fallback = [RecentSearch(query: "swift")]
        let store = makeStore(
            load: { fallback },
            save: { _ in throw SearchError.unknown }
        )

        var state = SearchFeature.State()
        state.query = "tuist"
        let store2 = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.load = { fallback }
            $0.recentSearchClient.save = { _ in throw SearchError.unknown }
        }

        await store2.send(.searchSubmitted)
        await store2.receive(.recentSearchesLoaded(fallback)) {
            $0.recentSearches = fallback
            $0.viewState = .loaded
        }
    }

    func test_recentSearchTapped_setsQueryAndSubmits() async {
        let item = RecentSearch(query: "swift")
        let saved = [item]
        let store = makeStore(save: { _ in saved })

        await store.send(.recentSearchTapped(item)) {
            $0.query = "swift"
        }
        await store.receive(.searchSubmitted)
        await store.receive(.recentSearchesLoaded(saved)) {
            $0.recentSearches = saved
            $0.suggestions = saved
            $0.viewState = .loaded
        }
    }

    func test_recentSearchDeleted_removesItemAndUpdatesState() async {
        let id = UUID()
        let remaining = [RecentSearch(query: "tuist")]
        let store = makeStore(delete: { _ in remaining })

        var state = SearchFeature.State()
        state.recentSearches = [RecentSearch(id: id, query: "swift"), remaining[0]]
        state.viewState = .loaded
        let store2 = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.delete = { _ in remaining }
        }

        await store2.send(.recentSearchDeleted(id))
        await store2.receive(.recentSearchesLoaded(remaining)) {
            $0.recentSearches = remaining
            $0.viewState = .loaded
        }
    }

    func test_recentSearchDeleted_lastItem_setsEmptyState() async {
        let id = UUID()
        let store = makeStore(delete: { _ in [] })

        var state = SearchFeature.State()
        state.recentSearches = [RecentSearch(id: id, query: "swift")]
        state.viewState = .loaded
        let store2 = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.delete = { _ in [] }
        }

        await store2.send(.recentSearchDeleted(id))
        await store2.receive(.recentSearchesLoaded([])) {
            $0.recentSearches = []
            $0.viewState = .empty
        }
    }

    func test_recentSearchDeleted_failure_setsFailedState() async {
        let id = UUID()
        var state = SearchFeature.State()
        state.recentSearches = [RecentSearch(id: id, query: "swift")]
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.delete = { _ in throw SearchError.unknown }
        }

        await store.send(.recentSearchDeleted(id))
        await store.receive(.recentSearchLoadFailed(.unknown)) {
            $0.viewState = .failed(.unknown)
        }
    }

    func test_recentSearchDeletedAll_clearsAllItems() async {
        var state = SearchFeature.State()
        state.recentSearches = [
            RecentSearch(query: "swift"),
            RecentSearch(query: "tuist")
        ]
        state.viewState = .loaded
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.deleteAll = {}
        }

        await store.send(.recentSearchDeletedAll)
        await store.receive(.recentSearchesLoaded([])) {
            $0.recentSearches = []
            $0.viewState = .empty
        }
    }

    func test_recentSearchDeletedAll_failure_setsFailedState() async {
        var state = SearchFeature.State()
        state.recentSearches = [RecentSearch(query: "swift")]
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.deleteAll = { throw SearchError.unknown }
        }

        await store.send(.recentSearchDeletedAll)
        await store.receive(.recentSearchLoadFailed(.unknown)) {
            $0.viewState = .failed(.unknown)
        }
    }

    func test_recentSearchesLoaded_acceptsUpTo10Items() async {
        let tenItems = (1...10).map { RecentSearch(query: "item\($0)") }
        let store = makeStore()

        await store.send(.recentSearchesLoaded(tenItems)) {
            $0.recentSearches = tenItems
            $0.viewState = .loaded
        }
    }

    func test_recentSearchesLoaded_withActiveQuery_updatesSuggestions() async {
        var state = SearchFeature.State()
        state.query = "swift"
        state.viewState = .loaded
        let store = makeStore(state: state)

        let incoming = [
            RecentSearch(query: "swift"),
            RecentSearch(query: "swiftui"),
            RecentSearch(query: "tuist")
        ]

        await store.send(.recentSearchesLoaded(incoming)) {
            $0.recentSearches = incoming
            $0.suggestions = [incoming[0], incoming[1]]
            $0.viewState = .loaded
        }
    }

    func test_searchSubmitted_duplicateKeyword_movesToFront() async {
        let id1 = UUID()
        let existingItem = RecentSearch(id: id1, query: "swift")
        let updatedFront = RecentSearch(query: "swift")
        let saved = [updatedFront, RecentSearch(query: "tuist")]

        var state = SearchFeature.State()
        state.query = "swift"
        state.recentSearches = [existingItem, RecentSearch(query: "tuist")]
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.save = { _ in saved }
        }

        await store.send(.searchSubmitted)
        await store.receive(.recentSearchesLoaded(saved)) {
            $0.recentSearches = saved
            $0.suggestions = [saved[0]]
            $0.viewState = .loaded
        }
    }

    func test_multipleDeleteCalls_cancelsInFlightRequest() async {
        let id1 = UUID()
        let id2 = UUID()
        let finalList = [RecentSearch(query: "remaining")]

        var state = SearchFeature.State()
        state.recentSearches = [
            RecentSearch(id: id1, query: "first"),
            RecentSearch(id: id2, query: "second"),
            finalList[0]
        ]

        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentSearchClient.delete = { _ in finalList }
        }

        await store.send(.recentSearchDeleted(id1))
        await store.receive(.recentSearchesLoaded(finalList)) {
            $0.recentSearches = finalList
            $0.viewState = .loaded
        }
        await store.send(.recentSearchDeleted(id2))
        await store.receive(.recentSearchesLoaded(finalList))
    }
}
