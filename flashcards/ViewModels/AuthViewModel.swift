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

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isBusy = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        await run {
            _ = try await Auth.auth().signIn(withEmail: self.email, password: self.password)
        }
    }

    func createAccount() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }
        await run {
            _ = try await Auth.auth().createUser(withEmail: self.email, password: self.password)
        }
    }

    func signOut() {
        do { try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func run(_ work: @escaping () async throws -> Void) async {
        errorMessage = nil
        isBusy = true
        defer { isBusy = false }
        do { try await work() }
        catch { errorMessage = error.localizedDescription }
    }
}
