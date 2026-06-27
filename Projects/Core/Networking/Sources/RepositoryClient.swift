import Foundation
import Models

// MARK: - RepositoryClient

public struct RepositoryClient: Sendable {
    public var searchRepositories: @Sendable (_ keyword: String, _ page: Int) async throws -> SearchResult

    public init(searchRepositories: @escaping @Sendable (String, Int) async throws -> SearchResult) {
        self.searchRepositories = searchRepositories
    }
}

// MARK: - Live

extension RepositoryClient {
    public static func live(session: URLSession = .shared) -> Self {
        RepositoryClient { keyword, page in
            guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://api.github.com/search/repositories?q=\(encodedKeyword)&page=\(page)")
            else {
                throw SearchError.network
            }

            var request = URLRequest(url: url)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SearchError.network
            }

            switch httpResponse.statusCode {
            case 200:
                break
            case 403:
                throw SearchError.rateLimited
            default:
                throw SearchError.network
            }

            do {
                let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: data)
                return dto.toDomain()
            } catch {
                throw SearchError.decoding
            }
        }
    }
}

// MARK: - DTO (private)

private struct SearchResponseDTO: Decodable {
    let totalCount: Int
    let items: [RepositoryDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }

    func toDomain() -> SearchResult {
        SearchResult(
            totalCount: totalCount,
            items: items.compactMap { $0.toDomain() }
        )
    }
}

private struct RepositoryDTO: Decodable {
    let id: Int
    let name: String
    let htmlUrl: String
    let description: String?
    let stargazersCount: Int
    let owner: OwnerDTO

    enum CodingKeys: String, CodingKey {
        case id, name, description, owner
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }

    func toDomain() -> GithubRepository? {
        guard let htmlURL = URL(string: htmlUrl) else { return nil }
        return GithubRepository(
            id: id,
            name: name,
            ownerLogin: owner.login,
            avatarURL: URL(string: owner.avatarUrl),
            htmlURL: htmlURL,
            description: description,
            stargazersCount: stargazersCount
        )
    }
}

private struct OwnerDTO: Decodable {
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
