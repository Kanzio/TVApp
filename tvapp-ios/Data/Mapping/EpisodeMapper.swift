import Foundation

struct EpisodeMapper {
    static func map(dto: EpisodeDTO) -> Episode {
        var imageURL: URL? = nil
        if let medium = dto.image?.medium {
            imageURL = URL(string: medium)
        } else if let original = dto.image?.original {
            imageURL = URL(string: original)
        }
        
        return Episode(
            id: dto.id,
            name: dto.name,
            season: dto.season,
            number: dto.number,
            summaryHTML: dto.summary,
            imageURL: imageURL,
            rating: dto.rating?.average
        )
    }
}
