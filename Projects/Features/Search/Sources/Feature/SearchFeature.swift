import ComposableArchitecture
import Foundation
import Models
import UseCase

@Reducer
public struct SearchFeature {

    @ObservableState
    public struct State: Equatable {
        public var query: String = ""
        public var recentSearches: [RecentSearch] = []
        public var suggestions: [RecentSearch] = []
        public var viewState: ViewState = .idle

        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded
            case empty
            case failed(SearchError)
        }

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case queryChanged(String)
        case querySuggestionDebounced
        case searchSubmitted
        case recentSearchTapped(RecentSearch)
        case recentSearchDeleted(UUID)
        case recentSearchDeletedAll
        case recentSearchesLoaded([RecentSearch])
        case recentSearchLoadFailed(SearchError)
    }

    @Dependency(\.recentSearchClient) var recentSearchClient
    @Dependency(\.continuousClock) var clock

    private enum CancelID {
        case suggestionDebounce
        case persistence
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                guard state.viewState == .idle else { return .none }
                state.viewState = .loading
                return .run { send in
                    do {
                        let items = try await recentSearchClient.load()
                        await send(.recentSearchesLoaded(items))
                    } catch {
                        await send(.recentSearchLoadFailed(.unknown))
                    }
                }
                .cancellable(id: CancelID.persistence, cancelInFlight: true)

            case let .queryChanged(query):
                state.query = query
                if query.isEmpty {
                    state.suggestions = []
                    state.viewState = state.recentSearches.isEmpty ? .empty : .loaded
                    return .cancel(id: CancelID.suggestionDebounce)
                }
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.querySuggestionDebounced)
                }
                .cancellable(id: CancelID.suggestionDebounce, cancelInFlight: true)

            case .querySuggestionDebounced:
                let query = state.query
                guard !query.isEmpty else { return .none }
                state.suggestions = state.recentSearches
                    .filter { $0.query.localizedCaseInsensitiveContains(query) }
                state.viewState = .loaded
                return .none

            case .searchSubmitted:
                let keyword = state.query.trimmingCharacters(in: .whitespaces)
                guard !keyword.isEmpty else { return .none }
                return .run { send in
                    do {
                        let items = try await recentSearchClient.save(keyword)
                        await send(.recentSearchesLoaded(items))
                    } catch {
                        let current = (try? await recentSearchClient.load()) ?? []
                        await send(.recentSearchesLoaded(current))
                    }
                }
                .cancellable(id: CancelID.persistence, cancelInFlight: true)

            case let .recentSearchTapped(item):
                state.query = item.query
                return .send(.searchSubmitted)

            case let .recentSearchDeleted(id):
                return .run { send in
                    do {
                        let items = try await recentSearchClient.delete(id)
                        await send(.recentSearchesLoaded(items))
                    } catch {
                        await send(.recentSearchLoadFailed(.unknown))
                    }
                }
                .cancellable(id: CancelID.persistence, cancelInFlight: true)

            case .recentSearchDeletedAll:
                return .run { send in
                    do {
                        try await recentSearchClient.deleteAll()
                        await send(.recentSearchesLoaded([]))
                    } catch {
                        await send(.recentSearchLoadFailed(.unknown))
                    }
                }
                .cancellable(id: CancelID.persistence, cancelInFlight: true)

            case let .recentSearchesLoaded(items):
                state.recentSearches = items
                if !state.query.isEmpty {
                    state.suggestions = items.filter {
                        $0.query.localizedCaseInsensitiveContains(state.query)
                    }
                }
                state.viewState = items.isEmpty && state.query.isEmpty ? .empty : .loaded
                return .none

            case let .recentSearchLoadFailed(error):
                state.viewState = .failed(error)
                return .none
            }
        }
    }

    public init() {}
}
