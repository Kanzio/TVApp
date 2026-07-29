import Foundation

protocol ShowRepositoryProtocol {
    func fetchShows(page: Int) async throws -> [Show]
    func fetchShow(id: Int) async throws -> Show
    func fetchSeasons(showId: Int) async throws -> [Season]
    func fetchEpisodes(seasonId: Int) async throws -> [Episode]
    func fetchCast(showId: Int) async throws -> [CastMember]
}
