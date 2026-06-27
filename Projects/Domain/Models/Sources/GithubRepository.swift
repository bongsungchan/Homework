import Foundation

public struct GithubRepository: Equatable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let owner: Owner
    public let htmlURL: URL
    public let description: String?
    public let stargazersCount: Int

    public init(
        id: Int,
        name: String,
        owner: Owner,
        htmlURL: URL,
        description: String?,
        stargazersCount: Int
    ) {
        self.id = id
        self.name = name
        self.owner = owner
        self.htmlURL = htmlURL
        self.description = description
        self.stargazersCount = stargazersCount
    }
}

extension GithubRepository {
    public struct Owner: Equatable, Sendable {
        public let login: String
        public let avatarURL: URL?

        public init(login: String, avatarURL: URL?) {
            self.login = login
            self.avatarURL = avatarURL
        }
    }
}
