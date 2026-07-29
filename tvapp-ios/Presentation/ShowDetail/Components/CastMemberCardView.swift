import SwiftUI

struct CastMemberCardView: View {
    let castMember: CastMember
    
    var body: some View {
        VStack(spacing: 8) {
            Group {
                if let url = castMember.personImageURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            VStack(spacing: 2) {
                Text(castMember.personName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(castMember.characterName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 90)
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "person.fill")
                .foregroundColor(.gray)
                .accessibilityHidden(true)
        }
    }
}
