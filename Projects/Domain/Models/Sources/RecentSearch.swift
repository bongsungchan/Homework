import Foundation

public struct RecentSearch: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let query: String
    public let date: Date

    public init(id: UUID = UUID(), query: String, date: Date = Date()) {
        self.id = id
        self.query = query
        self.date = date
    }
}
