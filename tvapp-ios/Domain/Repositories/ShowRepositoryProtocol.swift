import Foundation

protocol ShowRepositoryProtocol {
    func fetchShows(page: Int) async throws -> [Show]
    func fetchShow(id: Int) async throws -> Show
}
