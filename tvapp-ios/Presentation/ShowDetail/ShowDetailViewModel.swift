import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class ShowDetailViewModel {
    let show: Show
    private let repository: ShowRepositoryProtocol
    var seasonsState: ViewState<[Season]> = .loading
    var castState: ViewState<[CastMember]> = .loading
    var attributedSummary: AttributedString?
    var plainTextSummary: String = "No description available."
    
    init(show: Show, repository: ShowRepositoryProtocol) {
        self.show = show
        self.repository = repository
        
        if let html = show.summaryHTML {
            self.plainTextSummary = html.htmlStripped
        }
    }
    
    var formattedPremiereDate: String {
        guard let rawDate = show.premiereDateRaw else { return "Unknown" }
        return rawDate.formattedPremiereDate
    }
    
    func loadData() async {
        if let html = show.summaryHTML, attributedSummary == nil {
            self.attributedSummary = html.attributedHtmlString
        }
        
        if case .loading = seasonsState {
            await fetchSeasons()
        }
        
        if case .loading = castState {
            await fetchCast()
        }
    }
    
    private func fetchSeasons() async {
        print("fetchSeasons called for show \(show.id)")
        seasonsState = .loading
        do {
            let seasons = try await repository.fetchSeasons(showId: show.id)
            print("Fetched \(seasons.count) seasons")
            if seasons.isEmpty {
                seasonsState = .empty
            } else {
                seasonsState = .success(seasons)
            }
        } catch let error as NetworkError {
            print("Network error: \(error)")
            seasonsState = .error(errorMessage(for: error))
        } catch {
            print("Other error: \(error)")
            seasonsState = .error("Something went wrong while loading seasons. Please try again.")
        }
    }
    
    private func fetchCast() async {
        castState = .loading
        do {
            let cast = try await repository.fetchCast(showId: show.id)
            if cast.isEmpty {
                castState = .empty
            } else {
                castState = .success(cast)
            }
        } catch let error as NetworkError {
            castState = .error(errorMessage(for: error))
        } catch {
            castState = .error("Failed to load cast.")
        }
    }
    
    private func errorMessage(for error: NetworkError) -> String {
        switch error {
        case .noConnection:
            return "No internet connection."
        case .timeout:
            return "The request timed out."
        default:
            return "Failed to load seasons."
        }
    }
}
