import XCTest
import ComposableArchitecture
@testable import RepositoryWeb
import Models

@MainActor
final class RepositoryWebFeatureTests: XCTestCase {
    private func makeStore(repository: GithubRepository) -> TestStoreOf<RepositoryWebFeature> {
        TestStore(
            initialState: RepositoryWebFeature.State(repository: repository)
        ) {
            RepositoryWebFeature()
        }
    }

    func test_pageLoadFinished_setsIsLoadingFalse() async {
        let repo = GithubRepository(
            id: 1, name: "swift",
            owner: GithubRepository.Owner(login: "apple", avatarURL: nil),
            htmlURL: URL(string: "https://github.com/apple/swift")!,
            description: nil, stargazersCount: 0
        )
        let store = makeStore(repository: repo)

        await store.send(.pageLoadFinished) {
            $0.isLoading = false
        }
    }
}
