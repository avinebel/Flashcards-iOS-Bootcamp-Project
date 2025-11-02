//
//  Profile.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/2/25.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.gray)
            Text("Profile")
                .font(.title2.bold())
            Text("User settings and info coming soon.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
