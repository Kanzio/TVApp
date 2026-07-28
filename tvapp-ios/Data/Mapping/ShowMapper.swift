import Foundation

struct ShowMapper {
    static func map(dto: ShowDTO) -> Show {
        var posterThumbnailURL: URL? = nil
        if let medium = dto.image?.medium {
            posterThumbnailURL = URL(string: medium)
        }
        
        var posterLargeURL: URL? = nil
        if let original = dto.image?.original {
            posterLargeURL = URL(string: original)
        } else {
            posterLargeURL = posterThumbnailURL
        }
        
        var tvMazeURL: URL? = nil
        if let url = dto.url {
            tvMazeURL = URL(string: url)
        }
        
        return Show(
            id: dto.id,
            name: dto.name,
            posterThumbnailURL: posterThumbnailURL,
            posterLargeURL: posterLargeURL,
            ratingAverage: dto.rating?.average,
            summaryHTML: dto.summary,
            premiereDateRaw: dto.premiered,
            tvMazeURL: tvMazeURL
        )
    }
}
