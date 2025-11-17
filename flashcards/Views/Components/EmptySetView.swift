//
//  EmptySetView.swift
//  flashcards
//
//  Created by Jinseok Heo on 11/10/25.
//

import SwiftUI

struct EmptySetView: View {
    var body: some View {
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
    }
}
