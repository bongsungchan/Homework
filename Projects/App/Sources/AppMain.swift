import ComposableArchitecture
import SwiftUI
import Search
import SearchResult
import RepositoryWeb
import Models

// MARK: - App Entry Point

@main
struct GithubSearchApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}

// MARK: - AppFeature

@Reducer
struct AppFeature {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var search: SearchFeature.State = SearchFeature.State()
        var path: StackState<Path.State> = StackState()
    }

    // MARK: - Action

    enum Action: Equatable {
        case search(SearchFeature.Action)
        case path(StackActionOf<Path>)
    }

    // MARK: - Path

    @Reducer
    enum Path {
        case searchResult(SearchResultFeature)
        case repositoryWeb(RepositoryWebFeature)
    }

    // MARK: - body

    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }
        Reduce { state, action in
            switch action {
            case let .search(.searchSubmitted):
                let keyword = state.search.query.trimmingCharacters(in: .whitespaces)
                guard !keyword.isEmpty else { return .none }
                state.path.append(.searchResult(SearchResultFeature.State(keyword: keyword)))
                return .none

            case let .path(.element(_, action: .searchResult(.repositoryTapped(repo)))):
                state.path.append(.repositoryWeb(RepositoryWebFeature.State(repository: repo)))
                return .none

            case .search, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

// MARK: - AppRootView

struct AppRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            SearchView(store: store.scope(state: \.search, action: \.search))
        } destination: { pathStore in
            switch pathStore.case {
            case let .searchResult(resultStore):
                SearchResultView(store: resultStore)
            case let .repositoryWeb(webStore):
                RepositoryWebView(store: webStore)
            }
        }
    }
}
