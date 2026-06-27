import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI

public struct SearchResultView: View {

    @Bindable var store: StoreOf<SearchResultFeature>

    public init(store: StoreOf<SearchResultFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            switch store.viewState {
            case .idle, .loading:
                loadingView

            case .empty:
                EmptyStateView(
                    title: SearchError.empty.userFacingMessage,
                    message: "다른 키워드로 검색해 보세요."
                )
                .accessibilityElement(children: .combine)

            case let .failed(error):
                ErrorStateView(
                    title: "검색에 실패했어요.",
                    message: error.userFacingMessage,
                    retryTitle: "다시 시도"
                ) {
                    store.send(.retryTapped)
                }

            case .loaded:
                repositoryList
            }
        }
        .navigationTitle(store.keyword)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                principalTitle
            }
        }
        .onAppear { store.send(.onAppear) }
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("검색 결과를 불러오는 중입니다.")
            .accessibilityAddTraits(.updatesFrequently)
    }

    private var principalTitle: some View {
        Text(store.keyword)
            .font(.dsHeadline)
            .foregroundStyle(Color.dsPrimaryText)
            .lineLimit(1)
            .accessibilityLabel("\(store.keyword) 검색 결과")
    }

    private var repositoryList: some View {
        List {
            if store.totalCount > 0 {
                Text("\(store.totalCount.formatted())개 저장소")
                    .font(.dsFootnote)
                    .foregroundStyle(Color.dsSecondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.dsBackground)
                    .accessibilityLabel("총 \(store.totalCount.formatted())개 저장소")
            }

            ForEach(store.repositories) { repo in
                Button {
                    store.send(.repositoryTapped(repo))
                } label: {
                    RepositoryRowView(repository: repo)
                }
                .accessibilityLabel("\(repo.name), \(repo.owner.login)")
                .accessibilityHint("탭하면 저장소를 웹으로 열어요.")
                .listRowSeparator(.hidden)
                .listRowBackground(Color.dsBackground)
                .onAppear {
                    let threshold = 3
                    if let index = store.repositories.firstIndex(where: { $0.id == repo.id }),
                       index >= store.repositories.count - threshold {
                        store.send(.fetchNextPage)
                    }
                }
            }

            if let paginationError = store.paginationError {
                inlinePaginationError(paginationError)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.dsBackground)
            } else if store.isPaginationLoading {
                LoadingFooter()
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.dsBackground)
                    .accessibilityLabel("추가 결과를 불러오는 중입니다.")
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .listStyle(.plain)
        .background(Color.dsBackground)
    }

    private func inlinePaginationError(_ error: SearchError) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(DSColor.foregroundSecondary)
                .accessibilityHidden(true)

            Text(error.userFacingMessage)
                .font(.dsFootnote)
                .foregroundStyle(Color.dsSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button {
                store.send(.retryPaginationTapped)
            } label: {
                Text("다시 시도")
                    .font(.dsFootnote)
                    .foregroundStyle(Color.dsAccent)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("페이지 로드 실패, 다시 시도")
        }
        .padding(.vertical, DSSpacing.xs)
        .padding(.horizontal, DSSpacing.md)
        .accessibilityElement(children: .contain)
    }
}


#if DEBUG

private func makeStore(
    viewState: SearchResultFeature.State.ViewState = .loaded,
    repositories: [GithubRepository] = SearchResultView.sampleRepositories,
    totalCount: Int = 1234,
    isPaginationLoading: Bool = false,
    paginationError: SearchError? = nil
) -> StoreOf<SearchResultFeature> {
    var state = SearchResultFeature.State(keyword: "swift")
    state.viewState = viewState
    state.repositories = repositories
    state.totalCount = totalCount
    state.isPaginationLoading = isPaginationLoading
    state.paginationError = paginationError
    return Store(initialState: state) { SearchResultFeature() }
}

private func previewURL(_ s: String) -> URL { URL(string: s) ?? URL(fileURLWithPath: "/") }

private extension SearchResultView {
    static let sampleRepositories: [GithubRepository] = [
        GithubRepository(
            id: 1,
            name: "swift",
            owner: .init(login: "apple", avatarURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4")),
            htmlURL: previewURL("https://github.com/apple/swift"),
            description: "The Swift Programming Language",
            stargazersCount: 67_000
        ),
        GithubRepository(
            id: 2,
            name: "swift-package-manager",
            owner: .init(login: "apple", avatarURL: URL(string: "https://avatars.githubusercontent.com/u/10639145?v=4")),
            htmlURL: previewURL("https://github.com/apple/swift-package-manager"),
            description: "The Package Manager for the Swift Programming Language",
            stargazersCount: 9_500
        ),
        GithubRepository(
            id: 3,
            name: "Alamofire",
            owner: .init(login: "Alamofire", avatarURL: URL(string: "https://avatars.githubusercontent.com/u/7774181?v=4")),
            htmlURL: previewURL("https://github.com/Alamofire/Alamofire"),
            description: "Elegant HTTP Networking in Swift",
            stargazersCount: 40_000
        ),
    ]
}

#Preview("Loaded — Light") {
    NavigationStack {
        SearchResultView(store: makeStore())
    }
}

#Preview("Loaded — Dark") {
    NavigationStack {
        SearchResultView(store: makeStore())
    }
    .preferredColorScheme(.dark)
}

#Preview("Loaded — Dynamic Type AX3") {
    NavigationStack {
        SearchResultView(store: makeStore())
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("Loading (초기)") {
    NavigationStack {
        SearchResultView(store: makeStore(viewState: .loading, repositories: [], totalCount: 0))
    }
}

#Preview("Empty") {
    NavigationStack {
        SearchResultView(store: makeStore(viewState: .empty, repositories: [], totalCount: 0))
    }
}

#Preview("Full-screen Error — network") {
    NavigationStack {
        SearchResultView(store: makeStore(viewState: .failed(.network), repositories: [], totalCount: 0))
    }
}

#Preview("Full-screen Error — Dark") {
    NavigationStack {
        SearchResultView(store: makeStore(viewState: .failed(.rateLimited), repositories: [], totalCount: 0))
    }
    .preferredColorScheme(.dark)
}

#Preview("Pagination Loading") {
    NavigationStack {
        SearchResultView(store: makeStore(isPaginationLoading: true))
    }
}

#Preview("Pagination Error (인라인 재시도)") {
    NavigationStack {
        SearchResultView(store: makeStore(paginationError: .network))
    }
}

#Preview("Pagination Error — Dark") {
    NavigationStack {
        SearchResultView(store: makeStore(paginationError: .rateLimited))
    }
    .preferredColorScheme(.dark)
}

#endif
