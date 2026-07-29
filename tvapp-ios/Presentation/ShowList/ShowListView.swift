import SwiftUI

struct ShowListView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: ShowListViewModel

    init(viewModel: ShowListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading shows...")
                        .accessibilityLabel("Loading shows")

                case .success(let shows):
                    List {
                        ForEach(shows) { show in
                            NavigationLink(value: show) {
                                ShowRowView(show: show)
                            }
                            .onAppear {
                                // Trigger next page when the last item appears
                                if show == shows.last {
                                    Task { await viewModel.loadMoreShows() }
                                }
                            }
                        }

                        // Pagination footer
                        if viewModel.isPaginating {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .accessibilityLabel("Loading more shows")
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)

                case .error(let message):
                    ErrorStateView(message: message) {
                        viewModel.retry()
                    }

                case .empty:
                    EmptyStateView(message: "No shows available right now.")
                }
            }
            .navigationTitle("TV Shows")
            .navigationDestination(for: Show.self) { show in
                ShowDetailView(show: show, repository: dependencies.showRepository)
            }
        }
        .task {
            // Only fetch on initial load
            if case .loading = viewModel.state {
                await viewModel.fetchShows()
            }
        }
    }
}
