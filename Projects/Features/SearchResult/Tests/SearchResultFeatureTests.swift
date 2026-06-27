import XCTest
import ComposableArchitecture
@testable import SearchResult
import Models

@MainActor
final class SearchResultFeatureTests: XCTestCase {
    func test_onAppear_loadsRepositories() async {
        let repo = GithubRepository(
            id: 1, name: "swift", ownerLogin: "apple",
            avatarURL: nil, htmlURL: URL(string: "https://github.com/apple/swift")!,
            description: nil, stargazersCount: 0
        )
        let result = SearchResult(totalCount: 1, items: [repo])

        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in result }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
            $0.currentPage = 1
        }
        await store.receive(.repositoriesLoaded(result)) {
            $0.repositories = [repo]
            $0.totalCount = 1
            $0.currentPage = 2
            $0.hasNextPage = false
            $0.viewState = .loaded
        }
    }

    func test_onAppear_networkError_setsFailedState() async {
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in throw SearchError.network }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
            $0.currentPage = 1
        }
        await store.receive(.searchFailed(.network)) {
            $0.viewState = .failed(.network)
        }
    }
}
