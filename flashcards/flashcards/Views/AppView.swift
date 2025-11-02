//
//  AppView.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/2/25.
//
import SwiftUI

struct AppView: View {
    var body: some View {
        // Bottom App Bar
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    AppView()
}
