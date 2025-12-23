//
//  CosmicViewApp.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI

@main
struct CosmicViewApp: App {
    
    init() {
        // Configure a global URLSession cache (100 MB in memory, 500 MB on disk)
        // to aggressively cache APOD image responses for faster loads and offline use.
        URLCache.shared = URLCache(
            memoryCapacity: 100 * 1024 * 1024, // 100 MB RAM
            diskCapacity: 500 * 1024 * 1024,   // 500 MB disk
            diskPath: "apod-image-cache"
        )
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
