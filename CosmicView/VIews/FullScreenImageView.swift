//
//  FullScreenImageView.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI
import Photos

struct FullScreenImageView: View {

        let imageURL: String
    let title: String?
    let date: String?
    let copyright: String?
    let explanation: String?

    @Binding var isPresented: Bool

    
    @State private var showMetadata = true

    //  Save Feedback
    @State private var showSavedToast = false

    //  Zoom & Pan
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    //  Image & UI State
    @State private var loadedImage: UIImage?
    @State private var showPermissionAlert = false
    @State private var showShareSheet = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            //  Background
            Color.black.ignoresSafeArea()

            // Image Loader
            AsyncImage(url: URL(string: imageURL)) { phase in
                if let image = phase.image {
                    let uiImage = image.asUIImage()

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(zoomAndPanGesture)
                        .onTapGesture {
                            withAnimation {
                                showMetadata.toggle()
                            }
                        }
                        .onAppear {
                            loadedImage = uiImage
                            resetTransform()
                        }

                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            //  Metadata Overlay (Bottom)
            if showMetadata {
                VStack(alignment: .leading, spacing: 8) {

                    if let title {
                        Text(title)
                            .font(.headline)
                    }

                    if let date {
                        Text("📅 \(date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let copyright {
                        Text("© \(copyright)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if let explanation {
                        Text(explanation)
                            .font(.footnote)
                            .lineLimit(4)
                    }

                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            //  Top Controls
            HStack(spacing: 16) {

                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Button {
                    saveImage()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }

                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .foregroundColor(.white)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding()

            
            if showSavedToast {
                Text("Saved Image")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
            }
        }
        //  Alerts & Sheets
        .alert(
            "Photo Access Denied",
            isPresented: $showPermissionAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please allow photo access in Settings to save images.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = loadedImage {
                ShareSheet(items: [image])
            }
        }
    }

    //  Gestures
    private var zoomAndPanGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = min(max(lastScale * value, 1), 4)
                }
                .onEnded { _ in
                    lastScale = scale
                },

            DragGesture()
                .onChanged { value in
                    guard scale > 1 else { return }
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
                .onEnded { _ in
                    lastOffset = offset
                }
        )
    }

    //  Helpers
    private func resetTransform() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }

    private func saveImage() {
        guard let image = loadedImage else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    showPermissionAlert = true
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, _ in
                if success {
                    DispatchQueue.main.async {
                        withAnimation {
                            showSavedToast = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSavedToast = false
                            }
                        }
                    }
                }
            }
        }
    }
}

//  Image → UIImage Helper
extension Image {
    func asUIImage() -> UIImage {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage ?? UIImage()
    }
}
