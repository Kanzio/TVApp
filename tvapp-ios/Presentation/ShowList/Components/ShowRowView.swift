import SwiftUI

struct ShowRowView: View {
    let show: Show
    
    var body: some View {
        HStack(spacing: 16) {
            // Poster
            Group {
                if let url = show.posterThumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            placeholderView
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(width: 70, height: 100)
            .cornerRadius(8)
            .clipped()
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(show.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .accessibilityHidden(true)
                    
                    if let rating = show.ratingAverage {
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("N/A")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(show.name), rating \(show.ratingAverage.map { String(format: "%.1f", $0) } ?? "N/A")")
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "tv")
                .foregroundColor(.gray)
                .accessibilityHidden(true)
        }
    }
}
