import SwiftUI
import Models
import DesignSystem

// MARK: - RepositoryRowView

struct RepositoryRowView: View {
    let repository: GithubRepository

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: repository.avatarURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.dsSecondaryBackground
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(repository.name)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsPrimaryText)
                    .lineLimit(1)

                Text(repository.ownerLogin)
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsSecondaryText)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
