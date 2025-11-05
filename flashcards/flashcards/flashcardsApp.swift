//
//  flashcardsApp.swift
//  flashcards
//
//  Created by Avi Nebel on 10/28/25.
//

import SwiftUI


@main
struct flashcardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}


