//
//  AuthViewModel.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/4/25.
//

import SwiftUI
import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthState {
    case loading      // Initial check happening
    case signedOut    // No active user session
    case signedIn(userID: String) // Active user, ID is available
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var state: AuthState = .loading
    @Published var currentUser: AppUser?
    
    // Use on Sign In
    @Published var email = ""
    @Published var password = ""
    
    @Published var errorMessage: String?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        // Start by checking the initial session state
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            // This listener is the single source of truth for auth state
            if let user = user {
                // User is signed in
                self.state = .signedIn(userID: user.uid)
                // Fetch the user's data from Firestore
                Task {
                    await self.fetchCurrentUser(uid: user.uid)
                }
            } else {
                // User is not signed in
                self.state = .signedOut
                // Clear all user-specific data
                self.currentUser = nil
                self.email = ""
                self.password = ""
            }
        }
    }
    
    // Prevent lister to be running while it is not suppose to do
    deinit {
        if let h = authStateHandle { Auth.auth().removeStateDidChangeListener(h) }
    }

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        await runAuthOperation {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
        }
    }
    
    func fetchCurrentUser(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try document.data(as: AppUser.self)
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }

    func createAccount() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        await runAuthOperation {
            let result = try await Auth.auth().createUser(withEmail: self.email, password: self.password)
            
            // Create Firestore user document
            try await self.createUserDocument(
                uid: result.user.uid,
                email: self.email
            )
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func runAuthOperation(_ work: @escaping () async throws -> Void) async {
        errorMessage = nil
        let previousState = self.state // Capture the current state (signedOut or signedIn)
        self.state = .loading          // Set loading state temporarily
        
        defer {
            if case .loading = self.state {
                self.state = previousState
            }
        }
        
        do {
            try await work()
            // If successful, the authStateHandle closure will execute and set the final .signedIn state
        }
        catch {
            // If there's an error (e.g., wrong password), set the error message and revert state
            errorMessage = error.localizedDescription
            self.state = previousState
        }
    }
    
    private func createUserDocument(uid: String, email: String) async throws {
        let user = AppUser(
            id: uid,
            email: email
        )
        
        try db.collection("users")
            .document(uid)
            .setData(from: user)
        
        self.currentUser = user
        
        print("User document created for UID: \(uid)")
    }
}
