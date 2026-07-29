import SwiftUI

struct EpisodeRowView: View {
    let episode: Episode
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Image
            Group {
                if let url = episode.imageURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(width: 120, height: 68)
            .cornerRadius(8)
            .clipped()
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(episode.number). \(episode.name)")
                    .font(.headline)
                    .lineLimit(2)
                
                if let rating = episode.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .accessibilityHidden(true)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let summary = episode.summaryHTML {
                    Text(summary.htmlStripped)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "tv")
                .foregroundColor(.gray)
                .accessibilityHidden(true)
        }
    }
}
