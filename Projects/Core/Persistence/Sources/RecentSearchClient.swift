import Foundation
import Models

// MARK: - RecentSearchClient

public struct RecentSearchClient: Sendable {
    public var load: @Sendable () async throws -> [RecentSearch]
    public var save: @Sendable (_ keyword: String) async throws -> [RecentSearch]
    public var delete: @Sendable (_ id: UUID) async throws -> [RecentSearch]
    public var deleteAll: @Sendable () async throws -> Void

    public init(
        load: @escaping @Sendable () async throws -> [RecentSearch],
        save: @escaping @Sendable (String) async throws -> [RecentSearch],
        delete: @escaping @Sendable (UUID) async throws -> [RecentSearch],
        deleteAll: @escaping @Sendable () async throws -> Void
    ) {
        self.load = load
        self.save = save
        self.delete = delete
        self.deleteAll = deleteAll
    }
}

// MARK: - Live (UserDefaults)

extension RecentSearchClient {
    private static let maxCount = 10
    private static let storageKey = "com.kurly.githubsearch.recentSearches"

    public static func live(defaults: UserDefaults = .standard) -> Self {
        RecentSearchClient(
            load: {
                guard let data = defaults.data(forKey: storageKey),
                      let items = try? JSONDecoder().decode([RecentSearchDTO].self, from: data)
                else { return [] }
                return items.map(\.toDomain).sorted { $0.searchedAt > $1.searchedAt }
            },
            save: { keyword in
                var items = (try? await Self.live(defaults: defaults).load()) ?? []
                items.removeAll { $0.keyword == keyword }
                items.insert(RecentSearch(keyword: keyword), at: 0)
                if items.count > maxCount { items = Array(items.prefix(maxCount)) }
                let dtos = items.map(RecentSearchDTO.init)
                defaults.set(try? JSONEncoder().encode(dtos), forKey: storageKey)
                return items
            },
            delete: { id in
                var items = (try? await Self.live(defaults: defaults).load()) ?? []
                items.removeAll { $0.id == id }
                let dtos = items.map(RecentSearchDTO.init)
                defaults.set(try? JSONEncoder().encode(dtos), forKey: storageKey)
                return items
            },
            deleteAll: {
                defaults.removeObject(forKey: storageKey)
            }
        )
    }
}

// MARK: - DTO

private struct RecentSearchDTO: Codable {
    let id: UUID
    let keyword: String
    let searchedAt: Date

    init(_ model: RecentSearch) {
        self.id = model.id
        self.keyword = model.keyword
        self.searchedAt = model.searchedAt
    }

    var toDomain: RecentSearch {
        RecentSearch(id: id, keyword: keyword, searchedAt: searchedAt)
    }
}
