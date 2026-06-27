import ComposableArchitecture
import Models
import UseCase

// MARK: - SearchFeature

@Reducer
public struct SearchFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var query: String = ""
        public var recentSearches: [RecentSearch] = []
        public var suggestions: [RecentSearch] = []
        public var isLoading: Bool = false

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
        case queryChanged(String)
        case searchSubmitted
        case recentSearchTapped(RecentSearch)
        case recentSearchDeleted(UUID)
        case recentSearchDeletedAll
        case recentSearchesLoaded([RecentSearch])
    }

    // MARK: - Dependencies

    @Dependency(\.recentSearchClient) var recentSearchClient

    // MARK: - body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let items = (try? await recentSearchClient.load()) ?? []
                    await send(.recentSearchesLoaded(items))
                }

            case let .queryChanged(query):
                state.query = query
                state.suggestions = query.isEmpty
                    ? []
                    : state.recentSearches.filter { $0.keyword.localizedCaseInsensitiveContains(query) }
                return .none

            case .searchSubmitted:
                guard !state.query.trimmingCharacters(in: .whitespaces).isEmpty else { return .none }
                let keyword = state.query
                return .run { send in
                    let items = (try? await recentSearchClient.save(keyword)) ?? []
                    await send(.recentSearchesLoaded(items))
                }

            case let .recentSearchTapped(item):
                state.query = item.keyword
                return .send(.searchSubmitted)

            case let .recentSearchDeleted(id):
                return .run { send in
                    let items = (try? await recentSearchClient.delete(id)) ?? []
                    await send(.recentSearchesLoaded(items))
                }

            case .recentSearchDeletedAll:
                return .run { send in
                    try? await recentSearchClient.deleteAll()
                    await send(.recentSearchesLoaded([]))
                }

            case let .recentSearchesLoaded(items):
                state.recentSearches = items
                return .none
            }
        }
    }

    public init() {}
}
