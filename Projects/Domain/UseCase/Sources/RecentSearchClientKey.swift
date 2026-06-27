import ComposableArchitecture
import Persistence
import Models

// MARK: - TCA Dependency: RecentSearchClient

extension RecentSearchClient: DependencyKey {
    public static var liveValue: RecentSearchClient { .live() }
    public static var testValue: RecentSearchClient {
        RecentSearchClient(
            load: { [] },
            save: { _ in [] },
            delete: { _ in [] },
            deleteAll: {}
        )
    }
}

public extension DependencyValues {
    var recentSearchClient: RecentSearchClient {
        get { self[RecentSearchClient.self] }
        set { self[RecentSearchClient.self] = newValue }
    }
}
