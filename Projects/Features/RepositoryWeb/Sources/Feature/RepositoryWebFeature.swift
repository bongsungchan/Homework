import ComposableArchitecture
import Foundation
import Models

// MARK: - RepositoryWebFeature

@Reducer
public struct RepositoryWebFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var url: URL
        public var title: String
        public var isLoading: Bool = true

        public init(repository: GithubRepository) {
            self.url = repository.htmlURL
            self.title = repository.name
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case pageLoadStarted
        case pageLoadFinished
        case pageLoadFailed
    }

    // MARK: - body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .pageLoadStarted:
                state.isLoading = true
                return .none
            case .pageLoadFinished:
                state.isLoading = false
                return .none
            case .pageLoadFailed:
                state.isLoading = false
                return .none
            }
        }
    }

    public init() {}
}
