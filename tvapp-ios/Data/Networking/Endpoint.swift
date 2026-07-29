import Foundation

enum Endpoint {
    case shows(page: Int)
    case showDetails(id: Int)
    case seasons(showId: Int)
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.tvmaze.com"
        
        switch self {
        case .shows(let page):
            components.path = "/shows"
            components.queryItems = [URLQueryItem(name: "page", value: String(page))]
        case .showDetails(let id):
            components.path = "/shows/\(id)"
        case .seasons(let showId):
            components.path = "/shows/\(showId)/seasons"
        }
        
        return components.url
    }
}
