import SwiftUI

public struct EmptyStateView: View {
    public let title: String
    public let message: String

    public init(
        title: String = "결과 없음",
        message: String = "검색어를 바꿔서 다시 시도해 보세요."
    ) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(DSColor.foregroundTertiary)

            VStack(spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSFont.headlineMedium)
                    .foregroundColor(DSColor.foregroundPrimary)

                Text(message)
                    .font(DSFont.footnote)
                    .foregroundColor(DSColor.foregroundSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DSSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("EmptyStateView — Light") {
    EmptyStateView()
}

#Preview("EmptyStateView — Dark") {
    EmptyStateView(title: "No Results", message: "Try a different search term.")
        .preferredColorScheme(.dark)
}

#Preview("EmptyStateView — Large Text") {
    EmptyStateView()
        .dynamicTypeSize(.accessibility3)
}
#endif
