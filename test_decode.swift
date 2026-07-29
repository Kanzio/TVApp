import Foundation

struct ImageLinksDTO: Codable {
    let medium: String?
    let original: String?
}

struct SeasonDTO: Codable {
    let id: Int
    let number: Int?
    let episodeOrder: Int?
    let premiereDate: String?
    let endDate: String?
    let image: ImageLinksDTO?
    let summary: String?
}

let url = URL(string: "https://api.tvmaze.com/shows/1/seasons")!
let data = try! Data(contentsOf: url)
do {
    let seasons = try JSONDecoder().decode([SeasonDTO].self, from: data)
    print("Success: \(seasons.count)")
} catch {
    print("Decoding error: \(error)")
}
