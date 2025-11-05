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
    @State private var isSecure = true

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable().frame(width: 80, height: 80)
                .foregroundStyle(.gray)

            if let user = authVM.user {
                // if user logged in
                Text(user.email ?? "Signed in")
                    .font(.title3.weight(.semibold))

                Button(role: .destructive) {
                    authVM.signOut()
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)

            } else {
                // if user didn't log in
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
                        Button { isSecure.toggle() } label: {
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
                            if authVM.isBusy { ProgressView() }
                            Text("Sign in with Email")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(authVM.isBusy)

                    Button {
                        Task { await authVM.createAccount() }
                    } label: {
                        Text("Create New Account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(authVM.isBusy)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(error.contains("sent") ? .green : .red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
