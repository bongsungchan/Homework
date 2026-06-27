import Foundation

// MARK: - RecentSearch

public struct RecentSearch: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let keyword: String
    public let searchedAt: Date

    public init(id: UUID = UUID(), keyword: String, searchedAt: Date = Date()) {
        self.id = id
        self.keyword = keyword
        self.searchedAt = searchedAt
    }
}
