import Foundation
@testable import tvapp_ios

// MARK: - MockShowRepository

/// A configurable mock for `ShowRepositoryProtocol`.
final class MockShowRepository: ShowRepositoryProtocol {
    
    // MARK: - Stubs
    
    var fetchShowsResult: Result<[Show], Error> = .success([])
    var fetchShowResult: Result<Show, Error> = .success(Show.stub())
    var fetchSeasonsResult: Result<[Season], Error> = .success([])
    var fetchEpisodesResult: Result<[Episode], Error> = .success([])
    var fetchCastResult: Result<[CastMember], Error> = .success([])
    
    // MARK: - Call Tracking
    
    private(set) var fetchShowsCallCount = 0
    private(set) var fetchShowsPages: [Int] = []
    
    // MARK: - ShowRepositoryProtocol
    
    func fetchShows(page: Int) async throws -> [Show] {
        fetchShowsCallCount += 1
        fetchShowsPages.append(page)
        return try fetchShowsResult.get()
    }
    
    func fetchShow(id: Int) async throws -> Show {
        return try fetchShowResult.get()
    }
    
    func fetchSeasons(showId: Int) async throws -> [Season] {
        return try fetchSeasonsResult.get()
    }
    
    func fetchEpisodes(seasonId: Int) async throws -> [Episode] {
        return try fetchEpisodesResult.get()
    }
    
    func fetchCast(showId: Int) async throws -> [CastMember] {
        return try fetchCastResult.get()
    }
}

// MARK: - Show Stub Helper

extension Show {
    static func stub(
        id: Int = 1,
        name: String = "Test Show",
        ratingAverage: Double? = 8.5,
        summaryHTML: String? = "<p>Test summary</p>",
        premiereDateRaw: String? = "2023-01-01",
        posterThumbnailURL: URL? = nil,
        posterLargeURL: URL? = nil,
        tvMazeURL: URL? = URL(string: "https://www.tvmaze.com/shows/1/test-show")
    ) -> Show {
        Show(
            id: id,
            name: name,
            posterThumbnailURL: posterThumbnailURL,
            posterLargeURL: posterLargeURL,
            ratingAverage: ratingAverage,
            summaryHTML: summaryHTML,
            premiereDateRaw: premiereDateRaw,
            tvMazeURL: tvMazeURL
        )
    }
}
