import Foundation

extension String {
    var formattedPremiereDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: self) else {
            return self
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        return displayFormatter.string(from: date)
    }
}
