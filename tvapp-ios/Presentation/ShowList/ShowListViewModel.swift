import Foundation
import Observation

@MainActor
@Observable
class ShowListViewModel {
    private(set) var state: ViewState<[Show]> = .loading
    
    private let repository: ShowRepositoryProtocol
    private var isRequestInFlight = false
    
    init(repository: ShowRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchShows() async {
        guard !isRequestInFlight else { return }
        
        isRequestInFlight = true
        state = .loading
        
        do {
            let shows = try await repository.fetchShows(page: 0)
            if shows.isEmpty {
                state = .empty
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
    
    func retry() {
        Task {
            await fetchShows()
        }
    }
    
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
