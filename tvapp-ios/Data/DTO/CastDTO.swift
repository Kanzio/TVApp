import Foundation

struct CastDTO: Codable {
    let person: PersonDTO
    let character: CharacterDTO
}

struct PersonDTO: Codable {
    let id: Int
    let name: String
    let image: ImageLinksDTO?
}

struct CharacterDTO: Codable {
    let name: String
}
