//
//  EmptySetView.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/10/25.
//

import SwiftUI

struct EmptySetView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    
    var body: some View {
        if case AuthState.signedOut = authVM.getAuthState() {
            VStack(spacing: 12) {
                Image(systemName: "person.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("Not Logged In")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("Please navigate to the profile tab and sign in to get started")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .padding(.horizontal, 10)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "square.stack.3d.up.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("No Sets Yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("Create your first flashcard set to get started")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .padding(.horizontal, 10)
            
        }
        
    }
}
