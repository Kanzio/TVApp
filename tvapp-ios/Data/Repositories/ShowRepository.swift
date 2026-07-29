import Foundation

class ShowRepository: ShowRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchShows(page: Int) async throws -> [Show] {
        let endpoint = Endpoint.shows(page: page)
        let dtos: [ShowDTO] = try await networkService.request(endpoint)
        return dtos.map { ShowMapper.map(dto: $0) }
    }
    
    func fetchShow(id: Int) async throws -> Show {
        let endpoint = Endpoint.showDetails(id: id)
        let dto: ShowDTO = try await networkService.request(endpoint)
        return ShowMapper.map(dto: dto)
    }
    
    func fetchSeasons(showId: Int) async throws -> [Season] {
        let endpoint = Endpoint.seasons(showId: showId)
        let dtos: [SeasonDTO] = try await networkService.request(endpoint)
        return dtos.map { SeasonMapper.map(dto: $0) }
    }
    
    func fetchEpisodes(seasonId: Int) async throws -> [Episode] {
        let endpoint = Endpoint.episodes(seasonId: seasonId)
        let dtos: [EpisodeDTO] = try await networkService.request(endpoint)
        return dtos.map { EpisodeMapper.map(dto: $0) }
    }
    
    func fetchCast(showId: Int) async throws -> [CastMember] {
        let endpoint = Endpoint.cast(showId: showId)
        let dtos: [CastDTO] = try await networkService.request(endpoint)
        return dtos.map { CastMapper.map(dto: $0) }
    }
}
