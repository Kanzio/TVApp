import Foundation

struct Season: Identifiable, Equatable, Hashable {
    let id: Int
    let number: Int?
    let episodeOrder: Int?
    let premiereDate: String?
    let endDate: String?
    let posterURL: URL?
    let summaryHTML: String?
}
