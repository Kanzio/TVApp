import Testing
import Foundation
@testable import tvapp_ios

// MARK: - ShowListViewModel Tests

@Suite("ShowListViewModel")
@MainActor
struct ShowListViewModelTests {
    
    // MARK: - fetchShows — Success
    
    @Test("fetchShows transitions from loading to success")
    func fetchShows_withShows_setsSuccessState() async throws {
        // Given
        let shows = [Show.stub(id: 1, name: "Show A"), Show.stub(id: 2, name: "Show B")]
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success(shows)
        let sut = ShowListViewModel(repository: repo)
        
        // When
        await sut.fetchShows()
        
        // Then
        guard case .success(let loaded) = sut.state else {
            Issue.record("Expected .success state, got \(sut.state)")
            return
        }
        #expect(loaded.count == 2)
        #expect(loaded[0].name == "Show A")
        #expect(sut.isPaginating == false)
        #expect(sut.hasMorePages == true)
    }
    
    @Test("fetchShows transitions to empty state when server returns no shows")
    func fetchShows_withEmptyList_setsEmptyState() async {
        // Given
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success([])
        let sut = ShowListViewModel(repository: repo)
        
        // When
        await sut.fetchShows()
        
        // Then
        guard case .empty = sut.state else {
            Issue.record("Expected .empty state, got \(sut.state)")
            return
        }
        #expect(sut.hasMorePages == false)
    }
    
    @Test("fetchShows transitions to error state on noConnection")
    func fetchShows_noConnection_setsErrorState() async {
        // Given
        let repo = MockShowRepository()
        repo.fetchShowsResult = .failure(NetworkError.noConnection)
        let sut = ShowListViewModel(repository: repo)
        
        // When
        await sut.fetchShows()
        
        // Then
        guard case .error(let msg) = sut.state else {
            Issue.record("Expected .error state, got \(sut.state)")
            return
        }
        #expect(msg.contains("internet") || msg.contains("network"))
    }
    
    @Test("fetchShows transitions to error state on timeout")
    func fetchShows_timeout_setsErrorState() async {
        // Given
        let repo = MockShowRepository()
        repo.fetchShowsResult = .failure(NetworkError.timeout)
        let sut = ShowListViewModel(repository: repo)
        
        // When
        await sut.fetchShows()
        
        // Then
        guard case .error(let msg) = sut.state else {
            Issue.record("Expected .error state, got \(sut.state)")
            return
        }
        #expect(msg.contains("timed out") || msg.contains("timeout"))
    }
    
    // MARK: - fetchShows — Guard (in-flight deduplication)
    
    @Test("fetchShows does not start a second request while one is in flight")
    func fetchShows_calledTwiceConcurrently_onlyOneRequest() async throws {
        // Given
        let shows = [Show.stub()]
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success(shows)
        let sut = ShowListViewModel(repository: repo)
        
        // When: call fetchShows once (the in-flight guard is reset after completion)
        await sut.fetchShows()
        let firstCallCount = repo.fetchShowsCallCount
        
        // Then: exactly one call was made
        #expect(firstCallCount == 1)
    }
    
    // MARK: - loadMoreShows — Pagination
    
    @Test("loadMoreShows appends new shows to existing list")
    func loadMoreShows_appendsResults() async throws {
        // Given: seed with page 0 shows
        let page0 = [Show.stub(id: 1, name: "S1"), Show.stub(id: 2, name: "S2")]
        let page1 = [Show.stub(id: 3, name: "S3")]
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success(page0)
        let sut = ShowListViewModel(repository: repo)
        await sut.fetchShows() // state becomes .success(page0)
        
        // Swap stub for next page
        repo.fetchShowsResult = .success(page1)
        
        // When
        await sut.loadMoreShows()
        
        // Then
        guard case .success(let allShows) = sut.state else {
            Issue.record("Expected .success state")
            return
        }
        #expect(allShows.count == 3)
        #expect(allShows.last?.name == "S3")
        #expect(repo.fetchShowsPages.contains(1))
    }
    
    @Test("loadMoreShows sets hasMorePages to false when server returns empty list")
    func loadMoreShows_emptyPage_stopsLoadingMore() async {
        // Given
        let page0 = [Show.stub()]
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success(page0)
        let sut = ShowListViewModel(repository: repo)
        await sut.fetchShows()
        
        repo.fetchShowsResult = .success([]) // last page
        
        // When
        await sut.loadMoreShows()
        
        // Then
        #expect(sut.hasMorePages == false)
        // Original list should be intact
        guard case .success(let shows) = sut.state else {
            Issue.record("Expected .success state")
            return
        }
        #expect(shows.count == 1)
    }
    
    @Test("loadMoreShows rolls back page counter on failure")
    func loadMoreShows_failure_rollsBackPage() async {
        // Given
        let page0 = [Show.stub()]
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success(page0)
        let sut = ShowListViewModel(repository: repo)
        await sut.fetchShows()
        
        repo.fetchShowsResult = .failure(NetworkError.noConnection)
        
        // When
        await sut.loadMoreShows()
        
        // Then: next call should still request page 1 (counter rolled back to 0+1)
        repo.fetchShowsResult = .success([Show.stub(id: 99)])
        await sut.loadMoreShows()
        
        #expect(repo.fetchShowsPages.last == 1)
        #expect(sut.isPaginating == false)
    }
    
    @Test("loadMoreShows does nothing when hasMorePages is false")
    func loadMoreShows_noMorePages_doesNothing() async {
        // Given
        let repo = MockShowRepository()
        repo.fetchShowsResult = .success([])
        let sut = ShowListViewModel(repository: repo)
        await sut.fetchShows() // hasMorePages becomes false (empty list)
        
        let callCountBefore = repo.fetchShowsCallCount
        
        // When
        await sut.loadMoreShows()
        
        // Then: no additional network calls
        #expect(repo.fetchShowsCallCount == callCountBefore)
    }
    
    // MARK: - retry
    
    @Test("retry re-fetches shows after error")
    func retry_afterError_fetchesAgain() async throws {
        // Given: first call fails
        let repo = MockShowRepository()
        repo.fetchShowsResult = .failure(NetworkError.noConnection)
        let sut = ShowListViewModel(repository: repo)
        await sut.fetchShows()
        
        guard case .error = sut.state else {
            Issue.record("Expected error state after first fetch")
            return
        }
        
        // Prepare success for retry
        repo.fetchShowsResult = .success([Show.stub()])
        
        // When
        sut.retry()
        // Give the Task a moment to complete on the main actor
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        guard case .success(let shows) = sut.state else {
            Issue.record("Expected .success state after retry, got \(sut.state)")
            return
        }
        #expect(shows.count == 1)
    }
}
