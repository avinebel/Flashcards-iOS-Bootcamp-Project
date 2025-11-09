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

    // Replace WindowGroup body with debug-enabled wrapper
    var body: some Scene {
        WindowGroup {
            DebugRootView(authVM: authVM, logger: logger)
        }
    }
}

// Simple debug root that hosts your AppView but also provides
// a visible overlay + a TestView to help diagnose a plain white screen.
private struct DebugRootView: View {
    @ObservedObject var authVM: AuthViewModel
    let logger: Logger

    @State private var showTestView = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Primary app content (the real app)
            if !showTestView {
                AppView()
                    .environmentObject(authVM)
                    .transition(.opacity)
            } else {
                // Small test view to confirm UI rendering works
                TestView()
                    .transition(.opacity)
            }

            // Debug banner in top-right corner
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Debug: app started")
                            .font(.caption2)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        HStack {
                            Text(appeared ? "onAppear ✓" : "onAppear …")
                                .font(.caption2)
                            Button(action: toggleView) {
                                Text(showTestView ? "Show AppView" : "Show TestView")
                                    .font(.caption2).bold()
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(minHeight: 28)
                        }
                    }
                    .padding(10)
                }
                Spacer()
            }
        }
        .onAppear {
            // Log that the root view appeared
            appeared = true
            logger.log("DebugRootView onAppear — appeared = true")
            print("DebugRootView onAppear — appeared = true")
            // Log a basic authVM diagnostic if possible
            logger.log("AuthViewModel type: \(String(describing: type(of: authVM)))")
            print("AuthViewModel type: \(String(describing: type(of: authVM)))")
        }
        .animation(.default, value: showTestView)
    }

    private func toggleView() {
        showTestView.toggle()
        logger.log("toggleView — showTestView = \(showTestView)")
        print("toggleView — showTestView = \(showTestView)")
    }
}

// Minimal TestView to verify UI rendering path quickly
private struct TestView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("TestView — UI is rendering")
                .font(.title2)
                .bold()
            Text("If you see this, the white screen is likely inside AppView or its children.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            // Quick color band to make rendering obvious
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.9))
                .frame(height: 120)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}


