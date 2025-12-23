//
//  VideoPlaceholderView.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI

struct VideoPlaceholderView: View {

    let videoURL: String
    @State private var showVideo = false

    var body: some View {
        VStack(spacing: 12) {

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 220)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
            }
            .onTapGesture {
                showVideo = true
            }

            Text("This APOD is a video 🎬")
                .font(.headline)

            Text("Tap to watch on NASA / YouTube")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .sheet(isPresented: $showVideo) {
            VideoWebView(urlString: videoURL)
        }
    }
}
