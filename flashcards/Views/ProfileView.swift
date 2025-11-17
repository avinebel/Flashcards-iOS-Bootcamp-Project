//
//  Profile.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/2/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    private let grid = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch authVM.state {
                        case .loading:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        case .signedOut:
                            LoginView(authVM: authVM)
                        case .signedIn:
                            if let user = authVM.currentUser {
                                UserProfileCard(authVM: authVM, user: user)
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("My Sets")
                                        .font(.title2.bold())
                                        .padding(.horizontal)
                                }
                            } else {
                                // User is signed in, but we are fetching their user document from Firestore.
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .onAppear {
                // Fetch is called once on appear.
            }
        }
    }
}


struct UserProfileCard: View {
    @ObservedObject var authVM: AuthViewModel
    var user: AppUser
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Picture
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundStyle(.blue.gradient)
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.email)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Sign Out Button
            Button(role: .destructive) {
                authVM.signOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
}

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var isSecure: Bool = true
    
    var body: some View {
        let isAuthenticationProcessing: Bool = {
            switch authVM.state {
            case .loading:
                return true
            default:
                return false
            }
        }()
        
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.gray)
            
            Text("Login")
                .font(.title2.bold())
            
            VStack(spacing: 12) {
                TextField("Email", text: $authVM.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                HStack {
                    Group {
                        if isSecure {
                            SecureField("Password", text: $authVM.password)
                        } else {
                            TextField("Password", text: $authVM.password)
                        }
                    }
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                Button {
                    Task { await authVM.signIn() }
                } label: {
                    HStack {
                        if isAuthenticationProcessing {
                            ProgressView().tint(.white)
                        }
                        Text("Sign In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticationProcessing)
                
                Button {
                    Task { await authVM.createAccount() }
                } label: {
                    Text("Create New Account").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isAuthenticationProcessing)
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(error.contains("sent") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
