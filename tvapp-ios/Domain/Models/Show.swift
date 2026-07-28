import Foundation

struct Show: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let posterThumbnailURL: URL?
    let posterLargeURL: URL?
    let ratingAverage: Double?
    let summaryHTML: String?
    let premiereDateRaw: String?
    let tvMazeURL: URL?
}
