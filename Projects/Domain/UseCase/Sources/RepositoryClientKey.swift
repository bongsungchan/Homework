import ComposableArchitecture
import Networking
import Models

// MARK: - TCA Dependency: RepositoryClient

extension RepositoryClient: DependencyKey {
    public static var liveValue: RepositoryClient { .live() }
    public static var testValue: RepositoryClient {
        RepositoryClient { _, _ in
            SearchResult(totalCount: 0, items: [])
        }
    }
}

public extension DependencyValues {
    var repositoryClient: RepositoryClient {
        get { self[RepositoryClient.self] }
        set { self[RepositoryClient.self] = newValue }
    }
}
