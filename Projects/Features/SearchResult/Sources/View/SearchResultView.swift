import ComposableArchitecture
import SwiftUI
import Models
import DesignSystem

public struct SearchResultView: View {
    let store: StoreOf<SearchResultFeature>

    public init(store: StoreOf<SearchResultFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                switch viewStore.viewState {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .empty:
                    ContentUnavailableView(
                        "검색 결과가 없어요.",
                        systemImage: "magnifyingglass",
                        description: Text("다른 키워드로 검색해 보세요.")
                    )

                case let .failed(error):
                    failureView(error: error, viewStore: viewStore)

                case .loaded:
                    repositoryList(viewStore: viewStore)
                }
            }
            .navigationTitle(viewStore.keyword)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewStore.send(.onAppear) }
        }
    }

    @ViewBuilder
    private func repositoryList(viewStore: ViewStoreOf<SearchResultFeature>) -> some View {
        List {
            ForEach(viewStore.repositories) { repo in
                Button {
                    viewStore.send(.repositoryTapped(repo))
                } label: {
                    RepositoryRowView(repository: repo)
                }
                .onAppear {
                    if repo.id == viewStore.repositories.last?.id {
                        viewStore.send(.fetchNextPage)
                    }
                }
                .accessibilityLabel("\(repo.name), \(repo.owner.login)")
            }

            if let paginationError = viewStore.paginationError {
                inlinePaginationErrorView(error: paginationError, viewStore: viewStore)
            } else if viewStore.hasNextPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func failureView(error: SearchError, viewStore: ViewStoreOf<SearchResultFeature>) -> some View {
        VStack(spacing: 16) {
            Text(error.userFacingMessage)
                .font(.dsBody)
                .foregroundStyle(Color.dsSecondaryText)
                .multilineTextAlignment(.center)
            Button("다시 시도") { viewStore.send(.retryTapped) }
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func inlinePaginationErrorView(error: SearchError, viewStore: ViewStoreOf<SearchResultFeature>) -> some View {
        HStack {
            Text(error.userFacingMessage)
                .font(.dsCaption)
                .foregroundStyle(Color.dsSecondaryText)
            Spacer()
            Button("다시 시도") { viewStore.send(.retryPaginationTapped) }
                .font(.dsCaption)
        }
        .padding(.vertical, 8)
    }
}

private extension SearchError {
    var userFacingMessage: String {
        switch self {
        case .network:      return "인터넷 연결을 확인해 주세요."
        case .rateLimited:  return "요청이 많아요. 잠시 후 다시 시도해 주세요."
        case .empty:        return "검색 결과가 없어요."
        default:            return "오류가 발생했어요. 다시 시도해 주세요."
        }
    }
}
