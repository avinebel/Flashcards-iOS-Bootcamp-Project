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
        FirebaseApp.configure()
    }

    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(authVM)  // You can use authVM anywhere under AppView. 
        }
    }
}


