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
    @Published var errorMessage: String?
    
    @Published private var localDataUpdateTrigger: Bool = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private let localSetsKey = "LocalFlashcardSets"
    
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
            }
        }
    }
    
    // Prevent lister to be running while it is not suppose to do
    deinit {
        if let h = authStateHandle { Auth.auth().removeStateDidChangeListener(h) }
    }
    
    func getAuthState() -> AuthState {
        return state
    }
    
    func getCurrentUser() -> AppUser? {
        return currentUser
    }

    func signIn(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        await runAuthOperation {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
    }
    
    func fetchCurrentUser(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try document.data(as: AppUser.self)
        } catch {
            print("Error fetching user data: \(error.localizedDescription) \nTry create new account.")
            signOut()
        }
    }
    
    func uploadCurrentUser() async {
        guard let user = currentUser,
              case .signedIn(let uid) = state else {
            print("Error: Cannot upload user data. User is not signed in or currentUser is nil.")
            return
        }

        do {
            try db.collection("users")
                .document(uid)
                .setData(from: user)

            print("AuthViewModel: User document successfully uploaded/updated for UID: \(uid)")
        } catch {
            errorMessage = "Failed to upload user data: \(error.localizedDescription)"
            print("Error uploading user data: \(error.localizedDescription)")
        }
    }

    func createAccount(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        await runAuthOperation {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create Firestore user document
            try await self.createUserDocument(
                uid: result.user.uid,
                email: email
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
    
    // ** If User not Signed In **
    
    private func loadLocalFlashcardSets() -> [FlashcardSet] {
        guard let savedData = UserDefaults.standard.data(forKey: localSetsKey) else {
            return []
        }
        do {
            let sets = try JSONDecoder().decode([FlashcardSet].self, from: savedData)
            return sets
        } catch {
            print("Error decoding local flashcard sets: \(error)")
            return []
        }
    }
    
    private func saveLocalFlashcardSets(sets: [FlashcardSet]) {
        do {
            let encodedData = try JSONEncoder().encode(sets)
            UserDefaults.standard.set(encodedData, forKey: localSetsKey)
            print("AuthViewModel: Local sets saved successfully.")
        } catch {
            print("Error encoding and saving local flashcard sets: \(error)")
        }
    }
    
    // ** VM for accessing AppUser **
    var combinedFlashcardSets: [FlashcardSet] {
        _ = localDataUpdateTrigger
        switch state {
            case .signedIn:
                return currentUser?.flashcardSets ?? []
            case .signedOut, .loading:
                return loadLocalFlashcardSets()
        }
    }
    
    func getFlashcardSets() -> [FlashcardSet] {
        return combinedFlashcardSets
        
        
    }
    
    func addNewSet(newSet: FlashcardSet) {
        switch state {
            case .signedIn:
                currentUser?.flashcardSets.append(newSet)
                Task {
                    await uploadCurrentUser()
                }
            case .signedOut, .loading:
                var existingSets = loadLocalFlashcardSets()
                existingSets.append(newSet)
                saveLocalFlashcardSets(sets: existingSets)
                localDataUpdateTrigger.toggle()
        }
    }
    
    func updateSet(set updatedSet: FlashcardSet) async {
        switch state {
            case .signedIn:
                guard let index = currentUser?.flashcardSets.firstIndex(where: { $0.id == updatedSet.id }) else {
                    print("AuthViewModel: Set with ID \(updatedSet.id) not found in current user's remote sets.")
                    return
                }
                currentUser?.flashcardSets[index] = updatedSet
                await uploadCurrentUser()
            
            case .signedOut, .loading:
                var existingSets = loadLocalFlashcardSets()
                if let index = existingSets.firstIndex(where: { $0.id == updatedSet.id }) {
                    existingSets[index] = updatedSet
                    saveLocalFlashcardSets(sets: existingSets)
                    localDataUpdateTrigger.toggle()
                } else {
                    print("AuthViewModel: Set with ID \(updatedSet.id) not found in local sets.")
                }
        }
    }
    
}
