import Foundation

struct SeasonMapper {
    static func map(dto: SeasonDTO) -> Season {
        var posterURL: URL? = nil
        if let medium = dto.image?.medium {
            posterURL = URL(string: medium)
        } else if let original = dto.image?.original {
            posterURL = URL(string: original)
        }
        
        return Season(
            id: dto.id,
            number: dto.number,
            episodeOrder: dto.episodeOrder,
            premiereDate: dto.premiereDate,
            endDate: dto.endDate,
            posterURL: posterURL,
            summaryHTML: dto.summary
        )
    }
}
