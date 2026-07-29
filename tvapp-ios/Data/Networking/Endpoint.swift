import Foundation

enum Endpoint {
    case shows(page: Int)
    case showDetails(id: Int)
    case seasons(showId: Int)
    case episodes(seasonId: Int)
    case cast(showId: Int)
    
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
        case .episodes(let seasonId):
            components.path = "/seasons/\(seasonId)/episodes"
        case .cast(let showId):
            components.path = "/shows/\(showId)/cast"
        }
        
        return components.url
    }
}
