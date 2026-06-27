import ComposableArchitecture
import Models
import Persistence

extension RecentSearchClient: DependencyKey {
    public static var liveValue: RecentSearchClient { .live() }
}

public extension DependencyValues {
    var recentSearchClient: RecentSearchClient {
        get { self[RecentSearchClient.self] }
        set { self[RecentSearchClient.self] = newValue }
    }
}
