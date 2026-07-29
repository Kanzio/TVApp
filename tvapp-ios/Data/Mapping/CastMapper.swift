import Foundation

struct CastMapper {
    static func map(dto: CastDTO) -> CastMember {
        var personImageURL: URL? = nil
        if let medium = dto.person.image?.medium {
            personImageURL = URL(string: medium)
        } else if let original = dto.person.image?.original {
            personImageURL = URL(string: original)
        }
        
        return CastMember(
            personId: dto.person.id,
            personName: dto.person.name,
            personImageURL: personImageURL,
            characterName: dto.character.name
        )
    }
}
