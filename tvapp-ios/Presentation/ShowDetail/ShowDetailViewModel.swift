import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class ShowDetailViewModel {
    let show: Show
    
    init(show: Show) {
        self.show = show
    }
    
    var formattedPremiereDate: String {
        guard let rawDate = show.premiereDateRaw else { return "Unknown" }
        return rawDate.formattedPremiereDate
    }
    
    var attributedSummary: AttributedString? {
        guard let html = show.summaryHTML else { return nil }
        return html.attributedHtmlString
    }
    
    var plainTextSummary: String {
        guard let html = show.summaryHTML else { return "No description available." }
        return html.htmlStripped
    }
}
