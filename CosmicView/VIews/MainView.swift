//
//  MainVIew.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var apodViewModel = APODViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            ContentView(vm: apodViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(1)
        }
        .tint(.purple)
    }
}

#Preview {
    MainView()
}
