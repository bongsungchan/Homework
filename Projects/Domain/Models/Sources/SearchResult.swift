import Foundation

// MARK: - SearchResult

public struct SearchResult: Equatable, Sendable {
    public let totalCount: Int
    public let items: [GithubRepository]

    public init(totalCount: Int, items: [GithubRepository]) {
        self.totalCount = totalCount
        self.items = items
    }
}
