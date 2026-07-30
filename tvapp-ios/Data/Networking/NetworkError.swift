import Foundation

enum NetworkError: Error, Equatable {
    case noConnection
    case timeout
    case invalidResponse
    case decodingFailed
    case unknown(Error)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noConnection, .noConnection),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse),
             (.decodingFailed, .decodingFailed):
            return true
        case (.unknown(let lhsErr), .unknown(let rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        default:
            return false
        }
    }
}
