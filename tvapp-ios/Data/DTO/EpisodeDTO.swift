import Foundation

struct EpisodeDTO: Codable {
    let id: Int
    let name: String
    let season: Int
    let number: Int
    let summary: String?
    let image: ImageLinksDTO?
    let rating: RatingDTO?
}
