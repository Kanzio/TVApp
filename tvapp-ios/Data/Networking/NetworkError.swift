import Foundation

enum NetworkError: Error {
    case noConnection
    case timeout
    case invalidResponse
    case decodingFailed
    case unknown(Error)
}
