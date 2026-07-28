import SwiftUI

struct ShowListView: View {
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
                    List(shows) { show in
                        NavigationLink(value: show) {
                            ShowRowView(show: show)
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
                ShowDetailView(viewModel: ShowDetailViewModel(show: show))
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
