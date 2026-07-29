import Foundation

struct SeasonDTO: Codable {
    let id: Int
    let number: Int?
    let episodeOrder: Int?
    let premiereDate: String?
    let endDate: String?
    let image: ImageLinksDTO?
    let summary: String?
}
