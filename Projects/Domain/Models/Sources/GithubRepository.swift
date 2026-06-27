import Foundation

// MARK: - GithubRepository

public struct GithubRepository: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let ownerLogin: String
    public let avatarURL: URL?
    public let htmlURL: URL
    public let description: String?
    public let stargazersCount: Int

    public init(
        id: Int,
        name: String,
        ownerLogin: String,
        avatarURL: URL?,
        htmlURL: URL,
        description: String?,
        stargazersCount: Int
    ) {
        self.id = id
        self.name = name
        self.ownerLogin = ownerLogin
        self.avatarURL = avatarURL
        self.htmlURL = htmlURL
        self.description = description
        self.stargazersCount = stargazersCount
    }
}
