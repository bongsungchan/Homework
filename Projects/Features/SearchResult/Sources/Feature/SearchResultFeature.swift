import ComposableArchitecture
import Models
import UseCase

@Reducer
public struct SearchResultFeature {

    @ObservableState
    public struct State: Equatable {
        public var keyword: String
        public var repositories: [GithubRepository] = []
        public var totalCount: Int = 0
        public var currentPage: Int = 1
        public var hasNextPage: Bool = false
        public var isPaginationLoading: Bool = false
        public var viewState: ViewState = .idle
        public var paginationError: SearchError?

        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded
            case empty
            case failed(SearchError)
        }

        public init(keyword: String) {
            self.keyword = keyword
        }
    }

    public enum Action: Equatable {
        case onAppear
        case fetchNextPage
        case repositoriesLoaded(SearchResult)
        case searchFailed(SearchError)
        case paginationFailed(SearchError)
        case retryTapped
        case retryPaginationTapped
        case repositoryTapped(GithubRepository)
    }

    @Dependency(\.repositoryClient) var repositoryClient

    private enum CancelID { case search }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                state.viewState = .loading
                state.currentPage = 1
                state.isPaginationLoading = false
                state.paginationError = nil
                return search(keyword: state.keyword, page: 1)

            case .fetchNextPage:
                guard state.hasNextPage,
                      !state.isPaginationLoading,
                      state.paginationError == nil
                else { return .none }
                state.isPaginationLoading = true
                let page = state.currentPage
                return search(keyword: state.keyword, page: page)

            case let .repositoriesLoaded(result):
                let isFirstPage = state.currentPage == 1
                if isFirstPage {
                    state.repositories = result.items
                } else {
                    state.repositories += result.items
                }
                state.totalCount = result.totalCount
                state.currentPage += 1
                state.hasNextPage = state.repositories.count < result.totalCount
                state.isPaginationLoading = false
                state.paginationError = nil
                state.viewState = state.repositories.isEmpty ? .empty : .loaded
                return .none

            case let .searchFailed(error):
                // 빈 결과는 실패가 아니라 정상적인 빈 상태로 표시한다.
                state.viewState = error == .empty ? .empty : .failed(error)
                state.isPaginationLoading = false
                return .none

            case let .paginationFailed(error):
                state.paginationError = error
                state.isPaginationLoading = false
                return .none

            case .retryTapped:
                state.viewState = .loading
                state.currentPage = 1
                state.isPaginationLoading = false
                state.paginationError = nil
                return search(keyword: state.keyword, page: 1)

            case .retryPaginationTapped:
                state.paginationError = nil
                state.isPaginationLoading = true
                let page = state.currentPage
                return search(keyword: state.keyword, page: page)

            case .repositoryTapped:
                return .none
            }
        }
    }

    private func search(keyword: String, page: Int) -> Effect<Action> {
        .run { send in
            do {
                let result = try await repositoryClient.searchRepositories(keyword, page)
                await send(.repositoriesLoaded(result))
            } catch let error as SearchError {
                await send(page == 1 ? .searchFailed(error) : .paginationFailed(error))
            } catch {
                await send(page == 1 ? .searchFailed(.unknown) : .paginationFailed(.unknown))
            }
        }
        .cancellable(id: CancelID.search, cancelInFlight: true)
    }

    public init() {}
}
