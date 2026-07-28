import Foundation

class URLSessionNetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.unknown(NSError(domain: "Invalid URL", code: -1, userInfo: nil))
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingFailed
            }
            
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
