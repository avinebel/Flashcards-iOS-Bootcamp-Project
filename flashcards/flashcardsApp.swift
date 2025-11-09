//
//  flashcardsApp.swift
//  flashcards
//
//  Created by Avi Nebel on 10/28/25.
//

import SwiftUI
import FirebaseCore
import Combine
import os

@main
struct flashcardsApp: App {
    // Add a logger for early runtime diagnostics
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.avinebel.flashcards", category: "App")

    init() {
        // Log and try to configure Firebase; any crash or early exit might show up in logs/Console
        logger.log("flashcardsApp init — starting Firebase configuration")
        print("flashcardsApp init — starting Firebase configuration") // quick stdout fallback for simulator logs

        FirebaseApp.configure()

        logger.log("flashcardsApp init — Firebase configured")
        print("flashcardsApp init — Firebase configured")
    }

    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(authVM)  // You can use authVM anywhere under AppView. 
        }
    }
}


