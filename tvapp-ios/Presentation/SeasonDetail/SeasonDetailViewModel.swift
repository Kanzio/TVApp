import Foundation
import Observation

@MainActor
@Observable
class SeasonDetailViewModel {
    let season: Season
    private let repository: ShowRepositoryProtocol
    var episodesState: ViewState<[Episode]> = .loading
    
    init(season: Season, repository: ShowRepositoryProtocol) {
        self.season = season
        self.repository = repository
    }
    
    func fetchEpisodes() async {
        episodesState = .loading
        do {
            let episodes = try await repository.fetchEpisodes(seasonId: season.id)
            if episodes.isEmpty {
                episodesState = .empty
            } else {
                episodesState = .success(episodes)
            }
        } catch {
            episodesState = .error("Failed to load episodes. Please try again.")
        }
    }
}
