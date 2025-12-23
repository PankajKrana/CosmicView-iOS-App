//
//  SavedView.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI
import SwiftData

struct SavedView: View {

    @Query(sort: \FavoriteAPOD.date, order: .reverse)
    private var favorites: [FavoriteAPOD]

    @Environment(\.modelContext) private var context


    @State private var selectedAPOD: FavoriteAPOD?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
                Group {
                    if favorites.isEmpty {
                        emptyState
                    } else {
                        savedListView
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationSubtitle(Text("List of the saved APOD"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)

        }
    }
    
    // Convert Date to String
    private func dateFromString(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.date(from: value)
    }

}

extension SavedView {

    // MARK: Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.05, blue: 0.2),
                Color(red: 0.15, green: 0.1, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)

                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 12) {
                    Text("No Saved Items")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Save your favorite astronomy day to view them later.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            Spacer()
        }
    }

    // MARK: Saved List View
    private var savedListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(favorites) { apod in
                    savedItemCard(apod: apod)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    
    // MARK: Saved Item Card
    private func savedItemCard(apod: FavoriteAPOD) -> some View {
        NavigationLink {
            if let date = dateFromString(apod.date) {
                ContentView(
                    vm: APODViewModel(),
                    initialDate: date
                )
            }
        } label: {
            HStack(spacing: 16) {

                // Thumbnail
                if let url = URL(string: apod.imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            thumbnailPlaceholder
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            thumbnailFailure
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(apod.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(apod.date)
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.7))

                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(16)
            .background(glassMorphicCard(cornerRadius: 16))
        }
        .contextMenu {
            Button(role: .destructive) {
                context.delete(apod)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }


    // MARK: Helpers
    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(width: 80, height: 80)
            .overlay {
                ProgressView().tint(.white)
            }
    }

    private var thumbnailFailure: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.white.opacity(0.5))
            }
    }

    private func glassMorphicCard(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .shadow(color: .purple.opacity(0.3), radius: 20)
    }
}


#Preview {
    SavedView()
}
