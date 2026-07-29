import SwiftUI

struct SeasonDetailView: View {
    @State private var viewModel: SeasonDetailViewModel
    
    init(season: Season, repository: ShowRepositoryProtocol) {
        _viewModel = State(initialValue: SeasonDetailViewModel(season: season, repository: repository))
    }
    
    var body: some View {
        Group {
            switch viewModel.episodesState {
            case .loading:
                ProgressView("Loading episodes...")
            case .success(let episodes):
                List(episodes) { episode in
                    EpisodeRowView(episode: episode)
                }
                .listStyle(.plain)
            case .error(let message):
                Text(message).foregroundColor(.red)
            case .empty:
                Text("No episodes found.")
            }
        }
        .onAppear {
            if case .loading = viewModel.episodesState {
                Task {
                    await viewModel.fetchEpisodes()
                }
            }
        }
        .navigationTitle("Season \(viewModel.season.number ?? 0)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
