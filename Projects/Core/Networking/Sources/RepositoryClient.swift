import ComposableArchitecture
import Foundation
import Models
import OSLog

@DependencyClient
public struct RepositoryClient: Sendable {
    public var searchRepositories: @Sendable (_ keyword: String, _ page: Int) async throws -> SearchResult
}

extension RepositoryClient: DependencyKey {
    public static var liveValue: RepositoryClient { .live() }
    public static var testValue: RepositoryClient { RepositoryClient() }
}

public extension DependencyValues {
    var repositoryClient: RepositoryClient {
        get { self[RepositoryClient.self] }
        set { self[RepositoryClient.self] = newValue }
    }
}

extension RepositoryClient {
    public static func live(session: URLSession = .shared) -> Self {
        let logger = Logger(subsystem: "com.kurly.githubsearch", category: "Networking")

        return RepositoryClient(
            searchRepositories: { keyword, page in
                guard
                    let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: "https://api.github.com/search/repositories?q=\(encoded)&page=\(page)")
                else {
                    throw SearchError.network
                }

                var request = URLRequest(url: url)
                request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
                request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

                let data: Data
                let response: URLResponse

                do {
                    (data, response) = try await session.data(for: request)
                } catch let urlError as URLError {
                    logger.error("URLError: \(urlError.localizedDescription)")
                    throw SearchError.network
                } catch {
                    logger.error("Unknown network error: \(error.localizedDescription)")
                    throw SearchError.network
                }

                guard let http = response as? HTTPURLResponse else {
                    throw SearchError.network
                }

                try http.validateGitHub()

                do {
                    let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: data)
                    let result = dto.toDomain()
                    if result.items.isEmpty {
                        throw SearchError.empty
                    }
                    return result
                } catch let searchError as SearchError {
                    throw searchError
                } catch {
                    logger.error("Decoding error: \(error.localizedDescription)")
                    throw SearchError.decoding
                }
            }
        )
    }
}

private extension HTTPURLResponse {
    func validateGitHub() throws {
        switch statusCode {
        case 200 ..< 300:
            return
        case 403:
            throw SearchError.rateLimited
        case 422:
            throw SearchError.network
        default:
            throw SearchError.network
        }
    }
}

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
            owner: GithubRepository.Owner(
                login: owner.login,
                avatarURL: URL(string: owner.avatarUrl)
            ),
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
