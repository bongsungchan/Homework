import SwiftUI

public struct LoadingFooter: View {
    public let message: String

    public init(message: String = "불러오는 중…") {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            ProgressView()
                .tint(DSColor.foregroundSecondary)

            Text(message)
                .font(DSFont.footnote)
                .foregroundColor(DSColor.foregroundSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.md)
        .padding(.horizontal, DSSpacing.md)
    }
}

#if DEBUG
#Preview("LoadingFooter — Light") {
    List {
        ForEach(0 ..< 3, id: \.self) { i in
            Text("Row \(i)")
        }
        LoadingFooter()
            .listRowSeparator(.hidden)
    }
}

#Preview("LoadingFooter — Dark") {
    LoadingFooter(message: "Loading more…")
        .preferredColorScheme(.dark)
        .background(DSColor.containerBackground)
}
#endif
