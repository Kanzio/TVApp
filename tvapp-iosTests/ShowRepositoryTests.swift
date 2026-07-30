import Testing
import Foundation
@testable import tvapp_ios

// MARK: - ShowRepository Tests

@Suite("ShowRepository")
@MainActor
struct ShowRepositoryTests {
    
    // MARK: - fetchShows
    
    @Test("fetchShows maps DTOs to domain models correctly")
    func fetchShows_success_mapsToDomainModels() async throws {
        // Given
        let json = """
        [
          {
            "id": 42,
            "url": "https://www.tvmaze.com/shows/42/test",
            "name": "Under the Dome",
            "rating": { "average": 7.5 },
            "image": {
              "medium": "https://example.com/medium.jpg",
              "original": "https://example.com/original.jpg"
            },
            "summary": "<p>A dome appears.</p>",
            "premiered": "2013-06-24"
          }
        ]
        """.data(using: .utf8)!
        
        let mockNetwork = MockNetworkService()
        mockNetwork.stub = .success(json)
        let sut = ShowRepository(networkService: mockNetwork)
        
        // When
        let shows = try await sut.fetchShows(page: 0)
        
        // Then
        #expect(shows.count == 1)
        #expect(shows[0].id == 42)
        #expect(shows[0].name == "Under the Dome")
        #expect(shows[0].ratingAverage == 7.5)
        #expect(shows[0].summaryHTML == "<p>A dome appears.</p>")
        #expect(shows[0].premiereDateRaw == "2013-06-24")
        #expect(shows[0].posterThumbnailURL == URL(string: "https://example.com/medium.jpg"))
        #expect(shows[0].posterLargeURL == URL(string: "https://example.com/original.jpg"))
    }
    
    @Test("fetchShows handles null optional fields gracefully")
    func fetchShows_success_handlesNullFields() async throws {
        // Given
        let json = """
        [
          {
            "id": 1,
            "name": "Minimal Show",
            "url": null,
            "rating": null,
            "image": null,
            "summary": null,
            "premiered": null
          }
        ]
        """.data(using: .utf8)!
        
        let mockNetwork = MockNetworkService()
        mockNetwork.stub = .success(json)
        let sut = ShowRepository(networkService: mockNetwork)
        
        // When
        let shows = try await sut.fetchShows(page: 0)
        
        // Then
        #expect(shows.count == 1)
        #expect(shows[0].ratingAverage == nil)
        #expect(shows[0].posterThumbnailURL == nil)
        #expect(shows[0].summaryHTML == nil)
    }
    
    @Test("fetchShows falls back posterLargeURL to medium when original is missing")
    func fetchShows_success_fallbackPosterURL() async throws {
        // Given: only medium image provided
        let json = """
        [
          {
            "id": 1,
            "name": "Fallback Show",
            "url": null,
            "rating": null,
            "image": { "medium": "https://example.com/medium.jpg", "original": null },
            "summary": null,
            "premiered": null
          }
        ]
        """.data(using: .utf8)!
        
        let mockNetwork = MockNetworkService()
        mockNetwork.stub = .success(json)
        let sut = ShowRepository(networkService: mockNetwork)
        
        // When
        let shows = try await sut.fetchShows(page: 0)
        
        // Then: large URL falls back to medium
        #expect(shows[0].posterLargeURL == URL(string: "https://example.com/medium.jpg"))
    }
    
    @Test("fetchShows propagates noConnection error")
    func fetchShows_noConnection_throwsError() async {
        // Given
        let mockNetwork = MockNetworkService()
        mockNetwork.stub = .failure(NetworkError.noConnection)
        let sut = ShowRepository(networkService: mockNetwork)
        
        // When / Then
        await #expect(throws: NetworkError.noConnection) {
            _ = try await sut.fetchShows(page: 0)
        }
    }
    
    @Test("fetchShows propagates decodingFailed error")
    func fetchShows_badJSON_throwsDecodingError() async {
        // Given: malformed JSON
        let badJSON = "not json at all".data(using: .utf8)!
        let mockNetwork = MockNetworkService()
        mockNetwork.stub = .success(badJSON)
        let sut = ShowRepository(networkService: mockNetwork)
        
        // When / Then: JSON decoding will fail
        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchShows(page: 0)
        }
    }
    
    // MARK: - fetchSeasons
    
    @Test("fetchSeasons maps season DTOs correctly")
    func fetchSeasons_success_mapsToDomainModels() async throws {
        // Given
        let json = """
        [
          {
            "id": 1,
            "number": 1,
            "episodeOrder": 13,
            "premiereDate": "2013-06-24",
            "endDate": "2013-09-16",
            "image": {
              "medium": "https://example.com/season1.jpg",
              "original": null
            },
            "summary": ""
          }
        ]
        """.data(using: .utf8)!
        
        let mockNetwork = MockNetworkService()
        mockNetwork.stub = .success(json)
        let sut = ShowRepository(networkService: mockNetwork)
        
        // When
        let seasons = try await sut.fetchSeasons(showId: 1)
        
        // Then
        #expect(seasons.count == 1)
        #expect(seasons[0].id == 1)
        #expect(seasons[0].number == 1)
        #expect(seasons[0].episodeOrder == 13)
    }
}
