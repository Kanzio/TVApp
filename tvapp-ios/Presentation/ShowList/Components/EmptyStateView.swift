import SwiftUI

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tv.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Please check back later.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
