import Foundation
import Observation

@MainActor
@Observable
class AppDependencies {
    let networkService: NetworkServiceProtocol
    let showRepository: ShowRepositoryProtocol
    
    init() {
        self.networkService = URLSessionNetworkService()
        self.showRepository = ShowRepository(networkService: self.networkService)
    }
}
