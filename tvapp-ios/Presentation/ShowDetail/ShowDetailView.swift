import SwiftUI

struct ShowDetailView: View {
    @State private var viewModel: ShowDetailViewModel
    
    init(show: Show, repository: ShowRepositoryProtocol) {
        _viewModel = State(initialValue: ShowDetailViewModel(show: show, repository: repository))
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
                    
                    Divider()
                    
                    Text("Cast")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    switch viewModel.castState {
                    case .loading:
                        ProgressView("Loading cast...")
                            .padding(.top, 16)
                    case .success(let cast):
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(cast) { member in
                                    CastMemberCardView(castMember: member)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal, -16)
                    case .error(let message):
                        Text(message)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    case .empty:
                        Text("No cast available.")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Text("Seasons")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    switch viewModel.seasonsState {
                    case .loading:
                        ProgressView("Loading seasons...")
                            .padding(.top, 16)
                    case .success(let seasons):
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(seasons) { season in
                                    NavigationLink(value: season) {
                                        SeasonCardView(season: season)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal, -16)
                    case .error(let message):
                        Text(message)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    case .empty:
                        Text("No seasons available.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
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
