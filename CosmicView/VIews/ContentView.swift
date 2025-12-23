//
//  ContentView.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var vm: APODViewModel
    
    @State private var selectedDate = Date()
    @State private var showFullImage = false
    @State private var imageScale: CGFloat = 1.0
    
    private let apodStartDate = Calendar.current.date(
        from: DateComponents(year: 1995, month: 6, day: 16)
    )!
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    datePickerCard
                    contentArea
                }
                
                if showFullImage,
                   let url = vm.apod?.hdurl ?? vm.apod?.url {
                    FullScreenImageView(
                        imageURL: url,
                        title: vm.apod?.title,
                        date: vm.apod?.date,
                        copyright: vm.apod?.copyright,
                        explanation: vm.apod?.explanation,
                        isPresented: $showFullImage
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .navigationTitle("NASA APOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.windowBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            if vm.apod == nil {
                vm.fetch()
            }
        }
    }
}

extension ContentView {
    
    // Background
    
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
    
    // Date Picker
    
    private var datePickerCard: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.title2)
                    .foregroundStyle(gradientStyle)
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: apodStartDate...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(.purple)
                .onChange(of: selectedDate) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        vm.fetch(date: selectedDate)
                    }
                }
            }
            .padding()
            .background(glassMorphicCard(cornerRadius: 20))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // Content Area
    
    @ViewBuilder
    private var contentArea: some View {
        if vm.isLoading {
            loadingView
        } else if let apod = vm.apod {
            apodContentView(apod: apod)
        } else if let error = vm.errorMessage {
            errorView(message: error)
        }
    }
    
    // Loading View
    
    private var loadingView: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Loading cosmic wonders...")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
    }
    
    // APOD Content View
    
    private func apodContentView(apod: APOD) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                titleView(title: apod.title)
                mediaView(apod: apod)
                infoCard(apod: apod)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // Title View
    
    private func titleView(title: String) -> some View {
        Text(title)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.white, .white.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .lineLimit(3)
            .minimumScaleFactor(0.8)
    }
    
    // Media View
    
    @ViewBuilder
    private func mediaView(apod: APOD) -> some View {
        if apod.mediaType == "image",
           let url = URL(string: apod.url) {
            imageView(url: url)
        } else if apod.mediaType == "video" {
            VideoPlaceholderView(videoURL: apod.url)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .purple.opacity(0.4), radius: 30, x: 0, y: 15)
        }
    }
    
    // NOTE: AsyncImage with comprehensive phase handling
    
    private func imageView(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                imagePlaceholder
                
            case .success(let image):
                successImageView(image: image)
                
            case .failure:
                imageFailureView
                
            @unknown default:
                EmptyView()
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    
    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .overlay {
                ProgressView()
                    .tint(.white)
            }
    }
    
    
    private func successImageView(image: Image) -> some View {
        GeometryReader { geometry in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: 280)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(borderedOverlay(cornerRadius: 24))
                .shadow(color: .purple.opacity(0.4), radius: 30, x: 0, y: 15)
                .scaleEffect(imageScale)
                .onTapGesture {
                    handleImageTap()
                }
        }
        .frame(height: 280)
    }
    
    // Image Failure
    
    private var imageFailureView: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Unable to load image")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
    }
    
    // Info Card
    
    private func infoCard(apod: APOD) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            dateBadge(date: apod.date)
            descriptionText(text: apod.explanation)
            
            if let copyright = apod.copyright, !copyright.isEmpty {
                copyrightView(copyright: copyright)
            }
        }
        .padding(24)
        .background(glassMorphicCard(cornerRadius: 24))
    }
    
    // Date Badge
    
    private func dateBadge(date: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.caption)
            Text(date)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // Description Text
    
    private func descriptionText(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundStyle(.white.opacity(0.9))
            .lineSpacing(6)
            .padding(.top, 4)
    }
    
    // Copyright View
    
    private func copyrightView(copyright: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "c.circle")
                .font(.caption2)
            Text(copyright)
                .font(.caption)
        }
        .foregroundStyle(.white.opacity(0.6))
        .padding(.top, 4)
    }
    
    // Error View
    
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(message)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                retryButton
            }
            .padding()
            Spacer()
        }
    }
    
    // Retry Button
    
    private var retryButton: some View {
        Button {
            withAnimation {
                vm.fetch(date: selectedDate)
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Retry")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(gradientStyle)
                    .shadow(color: .purple.opacity(0.5), radius: 15, x: 0, y: 8)
            )
        }
    }
    
    // Reusable Styles
    
    private var gradientStyle: LinearGradient {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
    
        
    private func borderedOverlay(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
    
    
    // MARK: Image Tap Handler
    
    private func handleImageTap() {
        withAnimation(.spring(response: 0.3)) {
            imageScale = 0.95
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3)) {
                imageScale = 1.0
                showFullImage = true
            }
        }
    }
}



#Preview {
    ContentView(vm: APODViewModel())
}
