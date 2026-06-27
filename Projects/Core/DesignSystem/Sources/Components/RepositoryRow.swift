import SwiftUI

public struct RepositoryRow: View {
    public let avatarURL: URL?
    public let name: String
    public let description: String?

    public init(avatarURL: URL?, name: String, description: String?) {
        self.avatarURL = avatarURL
        self.name = name
        self.description = description
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            AsyncImage(url: avatarURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "person.crop.square")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(DSColor.foregroundTertiary)
                case .empty:
                    DSColor.Neutral.sN30
                @unknown default:
                    DSColor.Neutral.sN30
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.xs, style: .continuous))
            .dsShadow(.small)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(name)
                    .font(DSFont.bodyMedium)
                    .foregroundColor(DSColor.foregroundPrimary)
                    .lineLimit(1)

                if let description, !description.isEmpty {
                    Text(description)
                        .font(DSFont.footnote)
                        .foregroundColor(DSColor.foregroundSecondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DSSpacing.sm)
        .padding(.horizontal, DSSpacing.md)
        .background(DSColor.containerBackground)
    }
}

#if DEBUG
#Preview("RepositoryRow — Light") {
    VStack(spacing: 0) {
        RepositoryRow(
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/9919?v=4"),
            name: "github/github",
            description: "GitHub's main application repository"
        )
        Divider()
        RepositoryRow(
            avatarURL: nil,
            name: "swift-lang/swift",
            description: nil
        )
    }
}

#Preview("RepositoryRow — Dark") {
    VStack(spacing: 0) {
        RepositoryRow(
            avatarURL: nil,
            name: "apple/swift-package-manager",
            description: "The Package Manager for the Swift Programming Language"
        )
    }
    .preferredColorScheme(.dark)
}
#endif
