import Foundation

struct Episode: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let season: Int
    let number: Int
    let summaryHTML: String?
    let imageURL: URL?
    let rating: Double?
}
