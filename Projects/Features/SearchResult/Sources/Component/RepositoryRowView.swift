import DesignSystem
import Models
import SwiftUI

struct RepositoryRowView: View {

    let repository: GithubRepository

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            AsyncImage(url: repository.owner.avatarURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderAvatar
                case .empty:
                    placeholderAvatar
                @unknown default:
                    placeholderAvatar
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(repository.name)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsPrimaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(repository.owner.login)
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsSecondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, DSSpacing.xs)
        .background(Color.dsBackground)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    private var placeholderAvatar: some View {
        Circle()
            .fill(DSColor.foregroundTertiary.opacity(0.15))
            .overlay(
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .padding(DSSpacing.xs)
                    .foregroundStyle(DSColor.foregroundSecondary)
            )
    }
}

#if DEBUG

private func previewURL(_ s: String) -> URL { URL(string: s) ?? URL(fileURLWithPath: "/") }

private let sampleRepo = GithubRepository(
    id: 1,
    name: "swift",
    owner: .init(login: "apple", avatarURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4")),
    htmlURL: previewURL("https://github.com/apple/swift"),
    description: "The Swift Programming Language",
    stargazersCount: 67_000
)

private let longNameRepo = GithubRepository(
    id: 2,
    name: "very-long-repository-name-that-might-wrap-to-multiple-lines",
    owner: .init(login: "some-long-organization-name", avatarURL: nil),
    htmlURL: previewURL("https://github.com/example/repo"),
    description: nil,
    stargazersCount: 0
)

#Preview("RepositoryRowView — Light") {
    List {
        RepositoryRowView(repository: sampleRepo)
            .listRowSeparator(.hidden)
        RepositoryRowView(repository: longNameRepo)
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

#Preview("RepositoryRowView — Dark") {
    List {
        RepositoryRowView(repository: sampleRepo)
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}

#Preview("RepositoryRowView — Dynamic Type AX3") {
    List {
        RepositoryRowView(repository: sampleRepo)
            .listRowSeparator(.hidden)
        RepositoryRowView(repository: longNameRepo)
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .dynamicTypeSize(.accessibility3)
}

#endif
