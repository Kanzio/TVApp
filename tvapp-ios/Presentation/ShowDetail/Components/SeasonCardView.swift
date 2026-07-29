import SwiftUI

struct SeasonCardView: View {
    let season: Season
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if let url = season.posterURL {
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
            .frame(width: 120, height: 170)
            .cornerRadius(8)
            .clipped()
            
            Text("Season \(season.number ?? 0)")
                .font(.headline)
                .lineLimit(1)
            
            if let order = season.episodeOrder {
                Text("\(order) Episodes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
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
