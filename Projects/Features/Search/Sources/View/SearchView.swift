import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI

public struct SearchView: View {

    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        contentView
            .navigationTitle("Search")
            .searchable(
                text: $store.query.sending(\.queryChanged),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "저장소 검색"
            )
            .onSubmit(of: .search) {
                store.send(.searchSubmitted)
            }
            .onAppear { store.send(.onAppear) }
    }

    @ViewBuilder
    private var contentView: some View {
        switch store.viewState {
        case .idle:
            Color.dsBackground
                .accessibilityHidden(true)

        case .loading:
            loadingView

        case .empty:
            emptyRecentSearchView

        case .loaded:
            if store.query.isEmpty {
                recentSearchListView
            } else {
                suggestionsListView
            }

        case let .failed(error):
            errorView(error)
        }
    }

    private var loadingView: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)
            Text("불러오는 중...")
                .font(.dsFootnote)
                .foregroundStyle(Color.dsSecondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("최근 검색어를 불러오는 중입니다")
    }

    private var emptyRecentSearchView: some View {
        EmptyStateView(
            title: "최근 검색어 없음",
            message: "검색어를 입력하면 여기에 저장됩니다."
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("최근 검색어가 없습니다. 검색어를 입력하면 여기에 저장됩니다.")
    }

    private var recentSearchListView: some View {
        List {
            Section {
                ForEach(store.recentSearches) { item in
                    recentSearchRow(item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.recentSearchDeleted(item.id))
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            } header: {
                recentSearchHeader
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .accessibilityLabel("최근 검색어 목록")
    }

    private var recentSearchHeader: some View {
        HStack(alignment: .center) {
            Text("최근 검색")
                .font(.dsFootnote)
                .foregroundStyle(Color.dsSecondaryText)
                .textCase(nil)

            Spacer()

            Button {
                store.send(.recentSearchDeletedAll)
            } label: {
                Text("전체삭제")
                    .font(.dsFootnote)
                    .foregroundStyle(Color.dsAccent)
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("최근 검색어 전체 삭제")
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.xs)
        .frame(maxWidth: .infinity)
        .background(Color.dsBackground)
    }

    private func recentSearchRow(_ item: RecentSearch) -> some View {
        HStack(spacing: 0) {
            Button {
                store.send(.recentSearchTapped(item))
            } label: {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "clock")
                        .foregroundStyle(Color.dsSecondaryText)
                        .frame(width: 20, height: 20)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(item.query)
                            .font(.dsBody)
                            .foregroundStyle(Color.dsPrimaryText)
                            .lineLimit(1)

                        Text(item.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsSecondaryText)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.query), \(item.date.formatted(date: .abbreviated, time: .omitted))")
            .accessibilityHint("탭하면 검색합니다")

            Button {
                store.send(.recentSearchDeleted(item.id))
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.dsSecondaryText)
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .buttonStyle(.plain)
            .accessibilityLabel("\(item.query) 삭제")
        }
    }

    private var suggestionsListView: some View {
        Group {
            if store.suggestions.isEmpty {
                noSuggestionView
            } else {
                List(store.suggestions) { item in
                    suggestionRow(item)
                }
                .listStyle(.plain)
                .accessibilityLabel("자동완성 목록")
            }
        }
    }

    private var noSuggestionView: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Color.dsSecondaryText)
                .accessibilityHidden(true)

            Text("'\(store.query)'에 대한 최근 검색어가 없습니다")
                .font(.dsBody)
                .foregroundStyle(Color.dsSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("'\(store.query)'에 대한 최근 검색어가 없습니다")
    }

    private func suggestionRow(_ item: RecentSearch) -> some View {
        Button {
            store.send(.recentSearchTapped(item))
        } label: {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "arrow.up.left")
                    .foregroundStyle(Color.dsSecondaryText)
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)

                Text(item.query)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsPrimaryText)
                    .lineLimit(1)

                Spacer(minLength: DSSpacing.sm)

                Text(item.date.formatted(.dateTime.month().day()))
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsSecondaryText)
            }
            .contentShape(Rectangle())
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.query), \(item.date.formatted(date: .abbreviated, time: .omitted))")
        .accessibilityHint("탭하면 검색합니다")
    }

    private func errorView(_ error: SearchError) -> some View {
        ErrorStateView(
            message: error.userFacingMessage,
            onRetry: { store.send(.onAppear) }
        )
    }
}

#if DEBUG
import ComposableArchitecture

private func makeStore(
    viewState: SearchFeature.State.ViewState = .loaded,
    recentSearches: [RecentSearch] = [
        RecentSearch(query: "swift-composable-architecture", date: Date()),
        RecentSearch(query: "tuist", date: Date().addingTimeInterval(-86_400)),
        RecentSearch(query: "SwiftUI", date: Date().addingTimeInterval(-172_800)),
    ],
    query: String = ""
) -> StoreOf<SearchFeature> {
    var state = SearchFeature.State()
    state.viewState = viewState
    state.recentSearches = recentSearches
    state.query = query
    if !query.isEmpty {
        state.suggestions = recentSearches.filter {
            $0.query.localizedCaseInsensitiveContains(query)
        }
    }
    return Store(initialState: state) { SearchFeature() }
}

#Preview("최근 검색어 — Light") {
    NavigationStack { SearchView(store: makeStore()) }
}

#Preview("최근 검색어 — Dark") {
    NavigationStack { SearchView(store: makeStore()) }
        .preferredColorScheme(.dark)
}

#Preview("최근 검색어 없음 (Empty)") {
    NavigationStack { SearchView(store: makeStore(viewState: .empty, recentSearches: [])) }
}

#Preview("자동완성 (입력 중)") {
    NavigationStack { SearchView(store: makeStore(query: "swift")) }
}

#Preview("자동완성 결과 없음") {
    SearchView(store: makeStore(query: "zzzzz"))
}

#Preview("로딩") {
    SearchView(store: makeStore(viewState: .loading, recentSearches: []))
}

#Preview("에러") {
    SearchView(store: makeStore(viewState: .failed(.network), recentSearches: []))
}

#Preview("Dynamic Type — Accessibility3") {
    SearchView(store: makeStore())
        .dynamicTypeSize(.accessibility3)
}

#Preview("Dynamic Type — Dark + Accessibility3") {
    SearchView(store: makeStore())
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
