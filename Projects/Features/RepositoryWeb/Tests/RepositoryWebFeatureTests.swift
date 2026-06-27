import XCTest
import ComposableArchitecture
@testable import RepositoryWeb
import Models

private func testURL(_ s: String) -> URL { URL(string: s) ?? URL(fileURLWithPath: "/") }

private extension GithubRepository {
    static func make(
        id: Int = 1,
        name: String = "swift",
        login: String = "apple",
        htmlURL: URL = testURL("https://github.com/apple/swift"),
        description: String? = "The Swift Programming Language",
        stargazersCount: Int = 67_000
    ) -> GithubRepository {
        GithubRepository(
            id: id,
            name: name,
            owner: Owner(login: login, avatarURL: nil),
            htmlURL: htmlURL,
            description: description,
            stargazersCount: stargazersCount
        )
    }
}

@MainActor
final class RepositoryWebFeatureTests: XCTestCase {

    private func makeStore(
        repository: GithubRepository = .make()
    ) -> TestStoreOf<RepositoryWebFeature> {
        TestStore(
            initialState: RepositoryWebFeature.State(repository: repository)
        ) {
            RepositoryWebFeature()
        }
    }

    func test_initialState_urlAndTitleMappedFromRepository_isLoadingTrue() {
        let htmlURL = testURL("https://github.com/apple/swift")
        let repo = GithubRepository.make(name: "swift", htmlURL: htmlURL)

        let state = RepositoryWebFeature.State(repository: repo)

        XCTAssertEqual(state.url, htmlURL)
        XCTAssertEqual(state.title, "swift")
        XCTAssertTrue(state.isLoading, "초기 상태에서 isLoading은 true여야 한다.")
    }

    func test_pageLoadStarted_setsIsLoadingTrue() async {
        let store = makeStore()
        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }

        await store.send(.pageLoadStarted) {
            $0.isLoading = true
        }
    }

    func test_pageLoadStarted_whenAlreadyLoading_noStateChange() async {
        let store = makeStore()
        await store.send(.pageLoadStarted)
    }

    func test_pageLoadFinished_setsIsLoadingFalse() async {
        let store = makeStore()

        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
    }

    func test_pageLoadFinished_whenAlreadyFinished_noStateChange() async {
        let store = makeStore()

        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
        await store.send(.pageLoadFinished)
    }

    func test_pageLoadFailed_setsIsLoadingFalse() async {
        let store = makeStore()

        await store.send(.pageLoadFailed) {
            $0.isLoading = false
        }
    }

    func test_pageLoadFailed_whenAlreadyFailed_noStateChange() async {
        let store = makeStore()

        await store.send(.pageLoadFailed) {
            $0.isLoading = false
        }
        await store.send(.pageLoadFailed)
    }

    func test_dismissTapped_noStateChange_noEffect() async {
        let store = makeStore()
        await store.send(.dismissTapped)
    }

    func test_dismissTapped_afterLoadFinished_isLoadingRemainsfalse() async {
        let store = makeStore()

        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
        await store.send(.dismissTapped)
    }

    func test_loadSequence_startedThenFinished() async {
        let store = makeStore()

        await store.send(.pageLoadStarted)

        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
    }

    func test_loadSequence_startedThenFailed() async {
        let store = makeStore()

        await store.send(.pageLoadStarted)

        await store.send(.pageLoadFailed) {
            $0.isLoading = false
        }
    }

    func test_renavigation_afterFinished_isLoadingBecomesTrue() async {
        let store = makeStore()

        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
        await store.send(.pageLoadStarted) {
            $0.isLoading = true
        }
        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
    }

    func test_retryAfterFailure_succeeds() async {
        let store = makeStore()

        await store.send(.pageLoadFailed) {
            $0.isLoading = false
        }
        await store.send(.pageLoadStarted) {
            $0.isLoading = true
        }
        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
    }

    func test_differentRepositories_haveIndependentState() {
        let repoA = GithubRepository.make(
            id: 1,
            name: "swift",
            htmlURL: testURL("https://github.com/apple/swift")
        )
        let repoB = GithubRepository.make(
            id: 2,
            name: "tensorflow",
            htmlURL: testURL("https://github.com/tensorflow/tensorflow")
        )

        let stateA = RepositoryWebFeature.State(repository: repoA)
        let stateB = RepositoryWebFeature.State(repository: repoB)

        XCTAssertEqual(stateA.url, testURL("https://github.com/apple/swift"))
        XCTAssertEqual(stateA.title, "swift")

        XCTAssertEqual(stateB.url, testURL("https://github.com/tensorflow/tensorflow"))
        XCTAssertEqual(stateB.title, "tensorflow")

        XCTAssertNotEqual(stateA, stateB)
    }

    func test_repositoryWithNilAvatarURL_stateCreatedSuccessfully() {
        let repo = GithubRepository(
            id: 99,
            name: "repo-no-avatar",
            owner: .init(login: "org", avatarURL: nil),
            htmlURL: testURL("https://github.com/org/repo-no-avatar"),
            description: nil,
            stargazersCount: 0
        )

        let state = RepositoryWebFeature.State(repository: repo)

        XCTAssertEqual(state.title, "repo-no-avatar")
        XCTAssertEqual(state.url, testURL("https://github.com/org/repo-no-avatar"))
        XCTAssertTrue(state.isLoading)
    }
}
