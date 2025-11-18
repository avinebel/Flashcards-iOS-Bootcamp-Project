//
//  AppView.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/2/25.
//
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        @StateObject var setVM = SetSharingViewModel()
        // Bottom App Bar
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .environmentObject(setVM)
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
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
        .environmentObject(AuthViewModel()) // You might want to implement this for any preview
}
