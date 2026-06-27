import XCTest
import ComposableArchitecture
@testable import SearchResult
import Models

private func testURL(_ s: String) -> URL { URL(string: s) ?? URL(fileURLWithPath: "/") }

private func makeRepo(
    id: Int = 1,
    name: String = "swift",
    login: String = "apple",
    avatarURL: URL? = URL(string: "https://avatars.githubusercontent.com/u/10639145"),
    htmlURL: URL = testURL("https://github.com/apple/swift"),
    description: String? = "The Swift Programming Language",
    stars: Int = 0
) -> GithubRepository {
    GithubRepository(
        id: id,
        name: name,
        owner: GithubRepository.Owner(login: login, avatarURL: avatarURL),
        htmlURL: htmlURL,
        description: description,
        stargazersCount: stars
    )
}

private func makeResult(totalCount: Int, items: [GithubRepository]) -> SearchResult {
    SearchResult(totalCount: totalCount, items: items)
}

@MainActor
final class SearchResultFeatureTests: XCTestCase {

    func test_onAppear_success_setsLoadedStateWithRepositories() async {
        let repo = makeRepo()
        let result = makeResult(totalCount: 1, items: [repo])

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
            $0.isPaginationLoading = false
            $0.paginationError = nil
        }
        await store.receive(.repositoriesLoaded(result)) {
            $0.repositories = [repo]
            $0.totalCount = 1
            $0.currentPage = 2
            $0.hasNextPage = false
            $0.isPaginationLoading = false
            $0.paginationError = nil
            $0.viewState = .loaded
        }

        let stored = store.state.repositories[0]
        XCTAssertEqual(stored.name, "swift")
        XCTAssertEqual(stored.owner.login, "apple")
        XCTAssertNotNil(stored.owner.avatarURL)
    }

    func test_onAppear_emptyResult_setsEmptyState() async {
        let result = makeResult(totalCount: 0, items: [])

        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "empty-keyword")
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
            $0.totalCount = 0
            $0.repositories = []
            $0.currentPage = 2
            $0.hasNextPage = false
            $0.viewState = .empty
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
            $0.isPaginationLoading = false
        }
    }

    func test_onAppear_rateLimitedError_setsFailedState() async {
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in throw SearchError.rateLimited }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
            $0.currentPage = 1
        }
        await store.receive(.searchFailed(.rateLimited)) {
            $0.viewState = .failed(.rateLimited)
        }
    }

    func test_repositoryTapped_producesNoEffectInReducer() async {
        let repo = makeRepo()
        var state = SearchResultFeature.State(keyword: "swift")
        state.repositories = [repo]
        state.viewState = .loaded

        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in makeResult(totalCount: 1, items: [repo]) }
        }

        await store.send(.repositoryTapped(repo))
    }

    func test_fetchNextPage_appendsRepositoriesAndAdvancesPage() async {
        let page1Items = (1...3).map { makeRepo(id: $0, name: "repo\($0)", login: "owner\($0)") }
        let page2Items = (4...5).map { makeRepo(id: $0, name: "repo\($0)", login: "owner\($0)") }
        let page1Result = makeResult(totalCount: 5, items: page1Items)
        let page2Result = makeResult(totalCount: 5, items: page2Items)

        var callCount = 0
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                callCount += 1
                return callCount == 1 ? page1Result : page2Result
            }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
            $0.currentPage = 1
        }
        await store.receive(.repositoriesLoaded(page1Result)) {
            $0.repositories = page1Items
            $0.totalCount = 5
            $0.currentPage = 2
            $0.hasNextPage = true
            $0.viewState = .loaded
        }

        await store.send(.fetchNextPage) {
            $0.isPaginationLoading = true
        }
        await store.receive(.repositoriesLoaded(page2Result)) {
            $0.repositories = page1Items + page2Items
            $0.totalCount = 5
            $0.currentPage = 3
            $0.hasNextPage = false
            $0.isPaginationLoading = false
            $0.viewState = .loaded
        }
    }

    func test_fetchNextPage_whenNoNextPage_isIgnored() async {
        var state = SearchResultFeature.State(keyword: "swift")
        state.repositories = [makeRepo()]
        state.totalCount = 1
        state.currentPage = 2
        state.hasNextPage = false
        state.viewState = .loaded

        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                XCTFail("fetchNextPage should be ignored when hasNextPage is false")
                return makeResult(totalCount: 0, items: [])
            }
        }

        await store.send(.fetchNextPage)
    }

    func test_fetchNextPage_whenAlreadyPaginationLoading_isIgnored() async {
        var state = SearchResultFeature.State(keyword: "swift")
        state.hasNextPage = true
        state.isPaginationLoading = true

        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                XCTFail("Should not call while pagination is loading")
                return makeResult(totalCount: 0, items: [])
            }
        }

        await store.send(.fetchNextPage)
    }

    func test_fetchNextPage_whenPaginationErrorExists_isIgnored() async {
        var state = SearchResultFeature.State(keyword: "swift")
        state.hasNextPage = true
        state.isPaginationLoading = false
        state.paginationError = .network

        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                XCTFail("Should not call while paginationError exists")
                return makeResult(totalCount: 0, items: [])
            }
        }

        await store.send(.fetchNextPage)
    }

    func test_fetchNextPage_lastPageBoundary_hasNextPageBecomesfalse() async {
        let items = (1...10).map { makeRepo(id: $0, name: "r\($0)", login: "o\($0)") }
        let firstPage = makeResult(totalCount: 10, items: Array(items[0..<7]))
        let lastPage  = makeResult(totalCount: 10, items: Array(items[7...]))

        var callCount = 0
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                callCount += 1
                return callCount == 1 ? firstPage : lastPage
            }
        }

        await store.send(.onAppear) { $0.viewState = .loading; $0.currentPage = 1 }
        await store.receive(.repositoriesLoaded(firstPage)) {
            $0.repositories = Array(items[0..<7])
            $0.totalCount = 10
            $0.currentPage = 2
            $0.hasNextPage = true
            $0.viewState = .loaded
        }

        await store.send(.fetchNextPage) { $0.isPaginationLoading = true }
        await store.receive(.repositoriesLoaded(lastPage)) {
            $0.repositories = items
            $0.totalCount = 10
            $0.currentPage = 3
            $0.hasNextPage = false
            $0.isPaginationLoading = false
        }
    }

    func test_fetchNextPage_failure_setsPaginationError() async {
        let page1Items = (1...3).map { makeRepo(id: $0, name: "r\($0)", login: "o\($0)") }
        let page1Result = makeResult(totalCount: 10, items: page1Items)

        var callCount = 0
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                callCount += 1
                if callCount == 1 { return page1Result }
                throw SearchError.network
            }
        }

        await store.send(.onAppear) { $0.viewState = .loading; $0.currentPage = 1 }
        await store.receive(.repositoriesLoaded(page1Result)) {
            $0.repositories = page1Items
            $0.totalCount = 10
            $0.currentPage = 2
            $0.hasNextPage = true
            $0.viewState = .loaded
        }

        await store.send(.fetchNextPage) { $0.isPaginationLoading = true }
        await store.receive(.paginationFailed(.network)) {
            $0.paginationError = .network
            $0.isPaginationLoading = false
        }
    }

    func test_retryPaginationTapped_success_clearsPaginationErrorAndAppendsItems() async {
        let existingItems = (1...3).map { makeRepo(id: $0, name: "r\($0)", login: "o\($0)") }
        let nextItems = (4...6).map { makeRepo(id: $0, name: "r\($0)", login: "o\($0)") }
        let nextResult = makeResult(totalCount: 6, items: nextItems)

        var state = SearchResultFeature.State(keyword: "swift")
        state.repositories = existingItems
        state.totalCount = 6
        state.currentPage = 2
        state.hasNextPage = true
        state.viewState = .loaded
        state.paginationError = .network
        state.isPaginationLoading = false

        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in nextResult }
        }

        await store.send(.retryPaginationTapped) {
            $0.paginationError = nil
            $0.isPaginationLoading = true
        }
        await store.receive(.repositoriesLoaded(nextResult)) {
            $0.repositories = existingItems + nextItems
            $0.totalCount = 6
            $0.currentPage = 3
            $0.hasNextPage = false
            $0.isPaginationLoading = false
            $0.paginationError = nil
        }
    }

    func test_retryPaginationTapped_failure_keepsPaginationError() async {
        var state = SearchResultFeature.State(keyword: "swift")
        state.repositories = [makeRepo()]
        state.totalCount = 10
        state.currentPage = 2
        state.hasNextPage = true
        state.viewState = .loaded
        state.paginationError = .network

        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in throw SearchError.rateLimited }
        }

        await store.send(.retryPaginationTapped) {
            $0.paginationError = nil
            $0.isPaginationLoading = true
        }
        await store.receive(.paginationFailed(.rateLimited)) {
            $0.paginationError = .rateLimited
            $0.isPaginationLoading = false
        }
    }

    func test_retryTapped_afterFailure_resetsAndReloads() async {
        let repo = makeRepo()
        let result = makeResult(totalCount: 1, items: [repo])

        var callCount = 0
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                callCount += 1
                if callCount == 1 { throw SearchError.network }
                return result
            }
        }

        await store.send(.onAppear) { $0.viewState = .loading; $0.currentPage = 1 }
        await store.receive(.searchFailed(.network)) { $0.viewState = .failed(.network) }

        await store.send(.retryTapped) {
            $0.viewState = .loading
            $0.currentPage = 1
            $0.isPaginationLoading = false
            $0.paginationError = nil
        }
        await store.receive(.repositoriesLoaded(result)) {
            $0.repositories = [repo]
            $0.totalCount = 1
            $0.currentPage = 2
            $0.hasNextPage = false
            $0.viewState = .loaded
        }
    }

    func test_retryTapped_alsoFails_keepsFailedState() async {
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in throw SearchError.decoding }
        }

        await store.send(.onAppear) { $0.viewState = .loading; $0.currentPage = 1 }
        await store.receive(.searchFailed(.decoding)) { $0.viewState = .failed(.decoding) }

        await store.send(.retryTapped) {
            $0.viewState = .loading
            $0.currentPage = 1
        }
        await store.receive(.searchFailed(.decoding)) { $0.viewState = .failed(.decoding) }
    }

    func test_onAppear_calledTwice_cancelsInflightAndUsesLatest() async {
        let repo = makeRepo()
        let result = makeResult(totalCount: 1, items: [repo])

        var callCount = 0
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                callCount += 1
                if callCount == 1 {
                    try await Task.sleep(nanoseconds: 10_000_000_000)
                    return makeResult(totalCount: 99, items: [])
                }
                return result
            }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
            $0.currentPage = 1
        }
        await store.send(.onAppear)
        await store.receive(.repositoriesLoaded(result)) {
            $0.repositories = [repo]
            $0.totalCount = 1
            $0.currentPage = 2
            $0.hasNextPage = false
            $0.viewState = .loaded
        }
    }

    func test_onAppear_unknownError_mapsToUnknownSearchError() async {
        struct SomeRandomError: Error {}

        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in throw SomeRandomError() }
        }

        await store.send(.onAppear) { $0.viewState = .loading; $0.currentPage = 1 }
        await store.receive(.searchFailed(.unknown)) {
            $0.viewState = .failed(.unknown)
        }
    }

    func test_fetchNextPage_unknownError_mapsToUnknownPaginationError() async {
        let page1Items = [makeRepo()]
        let page1Result = makeResult(totalCount: 10, items: page1Items)
        struct Boom: Error {}

        var callCount = 0
        let store = TestStore(
            initialState: SearchResultFeature.State(keyword: "swift")
        ) {
            SearchResultFeature()
        } withDependencies: {
            $0.repositoryClient.searchRepositories = { _, _ in
                callCount += 1
                if callCount == 1 { return page1Result }
                throw Boom()
            }
        }

        await store.send(.onAppear) { $0.viewState = .loading; $0.currentPage = 1 }
        await store.receive(.repositoriesLoaded(page1Result)) {
            $0.repositories = page1Items
            $0.totalCount = 10
            $0.currentPage = 2
            $0.hasNextPage = true
            $0.viewState = .loaded
        }

        await store.send(.fetchNextPage) { $0.isPaginationLoading = true }
        await store.receive(.paginationFailed(.unknown)) {
            $0.paginationError = .unknown
            $0.isPaginationLoading = false
        }
    }
}
