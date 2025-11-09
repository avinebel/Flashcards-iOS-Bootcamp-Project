//
//  flashcardsApp.swift
//  flashcards
//
//  Created by Avi Nebel on 10/28/25.
//

import SwiftUI
import FirebaseCore
import Combine

@main
struct flashcardsApp: App {
    init() {
        // Only call FirebaseApp.configure() if GoogleService-Info.plist is present in the bundle.
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            // Avoid calling FirebaseApp.configure() because it throws if plist is missing.
            // The developer will add the plist from Firebase console; this prevents a crash until then.
            print("Warning: GoogleService-Info.plist not found in bundle. Skipping Firebase configuration.")
        }
    }

    @StateObject private var authVM = AuthViewModel()

    // Restore normal app entry without debug UI
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(authVM)
        }
    }
}


