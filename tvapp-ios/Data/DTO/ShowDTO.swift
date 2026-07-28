import Foundation

struct ShowDTO: Codable {
    let id: Int
    let url: String?
    let name: String
    let rating: RatingDTO?
    let image: ImageLinksDTO?
    let summary: String?
    let premiered: String?
}
