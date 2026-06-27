import ComposableArchitecture
import DesignSystem
import SwiftUI
import WebKit

public struct RepositoryWebView: View {

    @Bindable var store: StoreOf<RepositoryWebFeature>

    public init(store: StoreOf<RepositoryWebFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .top) {
            WebViewRepresentable(
                url: store.url,
                onLoadStarted:  { store.send(.pageLoadStarted)  },
                onLoadFinished: { store.send(.pageLoadFinished) },
                onLoadFailed:   { store.send(.pageLoadFailed)   }
            )
            .ignoresSafeArea(edges: .bottom)
            .accessibilityLabel(
                store.isLoading
                    ? "\(store.title) 로딩 중"
                    : "\(store.title) 웹 페이지"
            )

            if store.isLoading {
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(Color.dsAccent)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("페이지를 불러오는 중입니다.")
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .background(Color.dsBackground)
        .navigationTitle(store.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebViewRepresentable: UIViewRepresentable {

    let url: URL
    let onLoadStarted:  () -> Void
    let onLoadFinished: () -> Void
    let onLoadFailed:   () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLoadStarted:  onLoadStarted,
            onLoadFinished: onLoadFinished,
            onLoadFailed:   onLoadFailed
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.underPageBackgroundColor = UIColor.systemBackground
        webView.isOpaque = false
        webView.backgroundColor = .clear
        load(url: url, into: webView, coordinator: context.coordinator)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedURL != url else { return }
        load(url: url, into: webView, coordinator: context.coordinator)
    }

    private func load(url: URL, into webView: WKWebView, coordinator: Coordinator) {
        coordinator.loadedURL = url
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        webView.load(request)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {

        let onLoadStarted:  () -> Void
        let onLoadFinished: () -> Void
        let onLoadFailed:   () -> Void
        var loadedURL: URL?

        init(
            onLoadStarted:  @escaping () -> Void,
            onLoadFinished: @escaping () -> Void,
            onLoadFailed:   @escaping () -> Void
        ) {
            self.onLoadStarted  = onLoadStarted
            self.onLoadFinished = onLoadFinished
            self.onLoadFailed   = onLoadFailed
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            onLoadStarted()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoadFinished()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onLoadFailed()
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            onLoadFailed()
        }
    }
}

#if DEBUG
import Models

private func previewURL(_ s: String) -> URL { URL(string: s) ?? URL(fileURLWithPath: "/") }

private func makeStore(isLoading: Bool = false) -> StoreOf<RepositoryWebFeature> {
    let repo = GithubRepository(
        id: 1,
        name: "swift",
        owner: .init(login: "apple", avatarURL: previewURL("https://avatars.githubusercontent.com/u/10639145?v=4")),
        htmlURL: previewURL("https://github.com/apple/swift"),
        description: "The Swift Programming Language",
        stargazersCount: 67000
    )
    var state = RepositoryWebFeature.State(repository: repo)
    state.isLoading = isLoading
    return Store(initialState: state) { RepositoryWebFeature() }
}

#Preview("Light — loaded") {
    NavigationStack {
        RepositoryWebView(store: makeStore())
    }
}

#Preview("Dark — loading") {
    NavigationStack {
        RepositoryWebView(store: makeStore(isLoading: true))
    }
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type — AX3") {
    NavigationStack {
        RepositoryWebView(store: makeStore())
    }
    .dynamicTypeSize(.accessibility3)
}
#endif
