import SwiftUI

struct ShowDetailView: View {
    @State private var viewModel: ShowDetailViewModel
    
    init(viewModel: ShowDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Large Poster
                Group {
                    if let url = viewModel.show.posterLargeURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                placeholderView
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
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
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .clipped()
                
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(viewModel.show.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Premiere Date
                    Text("Premiered: \(viewModel.formattedPremiereDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Summary
                    if let summary = viewModel.attributedSummary {
                        Text(summary)
                            .font(.body)
                    } else {
                        Text(viewModel.plainTextSummary)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(viewModel.show.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: ShareContentBuilder.build(for: viewModel.show, plainTextSummary: viewModel.plainTextSummary)) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "tv")
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .accessibilityHidden(true)
        }
    }
}
