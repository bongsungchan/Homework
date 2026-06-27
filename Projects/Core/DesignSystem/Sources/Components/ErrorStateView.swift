import SwiftUI

public struct ErrorStateView: View {
    public let title: String
    public let message: String
    public let retryTitle: String
    public let onRetry: () -> Void

    public init(
        title: String = "오류가 발생했습니다",
        message: String = "잠시 후 다시 시도해 주세요.",
        retryTitle: String = "다시 시도",
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(DSColor.Red.s500)

            VStack(spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSFont.headlineMedium)
                    .foregroundColor(DSColor.foregroundPrimary)

                Text(message)
                    .font(DSFont.footnote)
                    .foregroundColor(DSColor.foregroundSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onRetry) {
                Text(retryTitle)
                    .font(DSFont.bodyMedium)
                    .foregroundColor(DSColor.Neutral.sN0)
                    .padding(.vertical, DSSpacing.sm)
                    .padding(.horizontal, DSSpacing.xl)
                    .background(DSColor.Blue.s500)
                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.xs, style: .continuous))
            }
        }
        .padding(DSSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("ErrorStateView — Light") {
    ErrorStateView(onRetry: {})
}

#Preview("ErrorStateView — Dark") {
    ErrorStateView(
        title: "Network Error",
        message: "Check your connection and try again.",
        retryTitle: "Retry",
        onRetry: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("ErrorStateView — Large Text") {
    ErrorStateView(onRetry: {})
        .dynamicTypeSize(.accessibility3)
}
#endif
