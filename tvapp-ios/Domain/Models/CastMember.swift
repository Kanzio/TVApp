import Foundation

struct CastMember: Identifiable, Equatable, Hashable {
    var id: String { "\(personId)-\(characterName)" }
    let personId: Int
    let personName: String
    let personImageURL: URL?
    let characterName: String
}
