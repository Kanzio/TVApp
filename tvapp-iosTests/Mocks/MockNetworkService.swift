import Foundation
@testable import tvapp_ios

// MARK: - MockNetworkService

/// A configurable mock for `NetworkServiceProtocol`.
/// Set `result` to control what each `request` call returns.
final class MockNetworkService: NetworkServiceProtocol {
    
    /// The value to return (as encoded JSON data) or the error to throw.
    enum Stub {
        case success(Data)
        case failure(Error)
    }
    
    var stub: Stub = .success(Data())
    private(set) var requestedEndpoints: [Endpoint] = []
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        switch stub {
        case .success(let data):
            return try JSONDecoder().decode(T.self, from: data)
        case .failure(let error):
            throw error
        }
    }
}
