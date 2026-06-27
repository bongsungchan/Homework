import Dependencies
import DependenciesMacros
import Foundation
import Models

@DependencyClient
public struct RecentSearchClient: Sendable {
    public var load: @Sendable () async throws -> [RecentSearch] = { [] }
    public var save: @Sendable (_ query: String) async throws -> [RecentSearch] = { _ in [] }
    public var delete: @Sendable (_ id: UUID) async throws -> [RecentSearch] = { _ in [] }
    public var deleteAll: @Sendable () async throws -> Void = {}
}

extension RecentSearchClient {
    private static let maxCount = 10
    private static let storageKey = "com.kurly.githubsearch.recentSearches"

    public static func live(defaults: UserDefaults = .standard) -> Self {
        func loadItems() -> [RecentSearch] {
            guard
                let data = defaults.data(forKey: storageKey),
                let dtos = try? JSONDecoder().decode([RecentSearchDTO].self, from: data)
            else { return [] }
            return dtos.map(\.toDomain).sorted { $0.date > $1.date }
        }

        func persist(_ items: [RecentSearch]) {
            let dtos = items.map(RecentSearchDTO.init)
            defaults.set(try? JSONEncoder().encode(dtos), forKey: storageKey)
        }

        return RecentSearchClient(
            load: {
                loadItems()
            },
            save: { query in
                var items = loadItems()
                items.removeAll { $0.query == query }
                items.insert(RecentSearch(query: query, date: Date()), at: 0)
                if items.count > maxCount {
                    items = Array(items.prefix(maxCount))
                }
                persist(items)
                return items
            },
            delete: { id in
                var items = loadItems()
                items.removeAll { $0.id == id }
                persist(items)
                return items
            },
            deleteAll: {
                defaults.removeObject(forKey: storageKey)
            }
        )
    }
}

private struct RecentSearchDTO: Codable {
    let id: UUID
    let query: String
    let date: Date

    init(_ model: RecentSearch) {
        self.id = model.id
        self.query = model.query
        self.date = model.date
    }

    var toDomain: RecentSearch {
        RecentSearch(id: id, query: query, date: date)
    }
}
