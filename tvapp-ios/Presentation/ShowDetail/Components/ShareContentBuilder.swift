import Foundation

struct ShareContentBuilder {
    static func build(for show: Show, plainTextSummary: String) -> String {
        var content = "\(show.name)\n\n"
        content += "\(plainTextSummary)\n\n"
        
        if let url = show.tvMazeURL {
            content += "View on TVMaze: \(url.absoluteString)"
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
