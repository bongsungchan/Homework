import ComposableArchitecture
import SwiftUI
import DesignSystem

// MARK: - SearchView

public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            List {
                if store.query.isEmpty {
                    recentSearchSection
                } else {
                    suggestionsSection
                }
            }
            .listStyle(.plain)
            .navigationTitle("GitHub 검색")
            .searchable(text: $store.query.sending(\.queryChanged), prompt: "저장소를 검색하세요")
            .onSubmit(of: .search) {
                store.send(.searchSubmitted)
            }
        }
        .onAppear { store.send(.onAppear) }
    }

    // MARK: - Sections

    @ViewBuilder
    private var recentSearchSection: some View {
        if !store.recentSearches.isEmpty {
            Section {
                ForEach(store.recentSearches) { item in
                    Button {
                        store.send(.recentSearchTapped(item))
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.keyword)
                                .font(.dsBody)
                                .foregroundStyle(Color.dsPrimaryText)
                            Text(item.searchedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.dsCaption)
                                .foregroundStyle(Color.dsSecondaryText)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.send(.recentSearchDeleted(item.id))
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                    .accessibilityLabel("\(item.keyword), \(item.searchedAt.formatted(date: .abbreviated, time: .omitted))")
                }
            } header: {
                HStack {
                    Text("최근 검색어")
                    Spacer()
                    Button("전체 삭제") { store.send(.recentSearchDeletedAll) }
                        .font(.dsCaption)
                }
            }
        }
    }

    @ViewBuilder
    private var suggestionsSection: some View {
        ForEach(store.suggestions) { item in
            Button {
                store.send(.recentSearchTapped(item))
            } label: {
                Text(item.keyword)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsPrimaryText)
            }
        }
    }
}
