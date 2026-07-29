import Foundation
import Observation

@MainActor
@Observable
class ShowListViewModel {
    // MARK: - State

    private(set) var state: ViewState<[Show]> = .loading
    private(set) var isPaginating = false
    private(set) var hasMorePages = true

    // MARK: - Private

    private let repository: ShowRepositoryProtocol
    private var currentPage = 0
    private var isRequestInFlight = false

    // MARK: - Init

    init(repository: ShowRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Actions

    /// Initial load — resets all state and fetches page 0.
    func fetchShows() async {
        guard !isRequestInFlight else { return }

        isRequestInFlight = true
        currentPage = 0
        hasMorePages = true
        state = .loading

        do {
            let shows = try await repository.fetchShows(page: currentPage)
            if shows.isEmpty {
                state = .empty
                hasMorePages = false
            } else {
                state = .success(shows)
            }
        } catch let error as NetworkError {
            state = .error(errorMessage(for: error))
        } catch {
            state = .error("Something went wrong while loading shows. Please try again.")
        }

        isRequestInFlight = false
    }

    /// Loads the next page and appends results to the existing list.
    func loadMoreShows() async {
        guard !isRequestInFlight, hasMorePages,
              case .success(let currentShows) = state else { return }

        isRequestInFlight = true
        isPaginating = true
        currentPage += 1

        do {
            let newShows = try await repository.fetchShows(page: currentPage)
            if newShows.isEmpty {
                hasMorePages = false
            } else {
                state = .success(currentShows + newShows)
            }
        } catch {
            // On pagination failure, silently roll back the page counter
            // and stop paginating — the existing list remains intact.
            currentPage -= 1
        }

        isRequestInFlight = false
        isPaginating = false
    }

    /// Retries the initial fetch after a failure.
    func retry() {
        Task {
            await fetchShows()
        }
    }

    // MARK: - Private Helpers

    private func errorMessage(for error: NetworkError) -> String {
        switch error {
        case .noConnection:
            return "No internet connection. Please check your network and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .invalidResponse:
            return "Something went wrong while loading shows. Please try again."
        case .decodingFailed:
            return "We couldn't process the data from the server. Please try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
