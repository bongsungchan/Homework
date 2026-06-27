import ComposableArchitecture
import SwiftUI
import WebKit

// MARK: - RepositoryWebView

public struct RepositoryWebView: View {
    let store: StoreOf<RepositoryWebFeature>

    public init(store: StoreOf<RepositoryWebFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .top) {
                WebViewRepresentable(
                    url: viewStore.url,
                    onLoadStarted: { viewStore.send(.pageLoadStarted) },
                    onLoadFinished: { viewStore.send(.pageLoadFinished) },
                    onLoadFailed: { viewStore.send(.pageLoadFailed) }
                )

                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(viewStore.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - WebViewRepresentable

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    let onLoadStarted: () -> Void
    let onLoadFinished: () -> Void
    let onLoadFailed: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLoadStarted: onLoadStarted,
            onLoadFinished: onLoadFinished,
            onLoadFailed: onLoadFailed
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onLoadStarted: () -> Void
        let onLoadFinished: () -> Void
        let onLoadFailed: () -> Void

        init(onLoadStarted: @escaping () -> Void, onLoadFinished: @escaping () -> Void, onLoadFailed: @escaping () -> Void) {
            self.onLoadStarted = onLoadStarted
            self.onLoadFinished = onLoadFinished
            self.onLoadFailed = onLoadFailed
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
    }
}
