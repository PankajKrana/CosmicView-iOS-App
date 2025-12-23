//
//  SavedView.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI

struct SavedView: View {
    
    @State private var savedAPODs: [APOD] = []
    @State private var selectedAPOD: APOD?
    @State private var showDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
                Group {
                    if savedAPODs.isEmpty {
                        emptyState
                    } else {
                        savedListView
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)        }
    }
}

//  View Components Extension

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
        .ignoresSafeArea()
    }
    
    // MARK: Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                // Animated bookmark icon
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
                    
                    Text("Save your favorite astronomy pictures to view them later.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                
                // Instruction card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.title3)
                            .foregroundStyle(.yellow)
                        
                        Text("Quick Tip")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    
                    Text("Tap the bookmark icon on any APOD to save it here for quick access.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(20)
                .background(glassMorphicCard(cornerRadius: 20))
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    //  Saved List View
    
    private var savedListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(savedAPODs) { apod in
                    savedItemCard(apod: apod)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    //  Saved Item Card
    
    private func savedItemCard(apod: APOD) -> some View {
        Button {
            selectedAPOD = apod
            showDetail = true
        } label: {
            HStack(spacing: 16) {
                // Thumbnail
                if apod.mediaType == "image",
                   let url = URL(string: apod.url) {
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
                } else {
                    videoThumbnail
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(apod.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(apod.date)
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    
                    if let copyright = apod.copyright, !copyright.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "c.circle")
                                .font(.caption2)
                            Text(copyright)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(16)
            .background(glassMorphicCard(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // Thumbnail Placeholder
    
    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(width: 80, height: 80)
            .overlay {
                ProgressView()
                    .tint(.white)
            }
    }
    
    // Thumbnail Failure
    
    private var thumbnailFailure: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.white.opacity(0.5))
            }
    }
    
    // MARK: Video Thumbnail
    
    private var videoThumbnail: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
    }
    
    
    
    private func glassMorphicCard(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

//  Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}



#Preview {
    SavedView()
}
